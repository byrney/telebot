module Telebot
  class Client
    API_URL = "https://api.telegram.org"

    def initialize(token)
      @token = token

      @faraday = Faraday.new(API_URL) do |conn|
        conn.request :multipart
        conn.request :url_encoded
        conn.response :json, :content_type => /\bjson$/
        conn.adapter Faraday.default_adapter
      end

    end

    # @return [Array<Telebot::Update>]
    def get_updates(offset: nil, limit: nil, timeout: nil)
      result = send_request(:getUpdates, offset: offset, limit: limit, timeout: timeout)
      result.map { |update_hash| Update.new(update_hash) }
    end

    def send_message(chat_id:, text:, disable_web_page_preview: false, reply_to_message_id: nil, reply_markup: nil)
      result = send_request(:sendMessage,
        chat_id: chat_id,
        text: text,
        disable_web_page_preview: disable_web_page_preview,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup
      )
      Message.new(result)
    end


    # @param chat_id [Integer] Unique identifier for the message recipient - User or GroupChat id
    # @param photo [InputFile, String] Photo to send. You can either pass a
    #   file_id as String to resend a photo that is already on the Telegram servers,
    #   or upload a new photo using multipart/form-data.
    # @param caption [String] Photo caption (may also be used when resending photos by file_id)
    # @param reply_to_message_id [Integer] If the message is a reply, ID of the original message
    # @param reply_markup [ReplyKeyboardMarkup, ReplyKeyboardHide, ForceReply]
    #   Additional interface options. A JSON-serialized object for a custom reply
    #   keyboard, instructions to hide keyboard or to force a reply from the user.
    def send_photo(chat_id:, photo:, caption: nil, reply_to_message_id: nil, reply_markup: nil)
      result = send_request(:sendPhoto,
        chat_id: chat_id,
        photo: photo,
        caption: caption,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup
      )
      Message.new(result)
    end

    private def send_request(method_name, params)
      path = "/bot#{@token}/#{method_name}"
      faraday_response = @faraday.post(path, params)

      response = Response.new(faraday_response.body)

      if response.ok
        response.result
      else
        puts "ERROR: #{response.description}"
        nil
      end
    end
  end
end