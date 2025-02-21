

module Model
  module EventMessages
    # settings changed message model used to inform components that the settings have changed
    class MessageBoxMessage
      attr_reader :message_text


      def initialize(message_text = '')
        @message_text = message_text
      end

      def to_s
        "ForceReloadMessage: #{@message}"
      end
    end
  end
end
