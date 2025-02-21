# frozen_string_literal: true

module Model
  module EventMessages
    # settings changed message model used to inform components that the settings have changed
    class StatusBarTextMessage
      attr_reader :message, :color

      def initialize(message: '', color: :white)
        @message = message
        @color = color
      end

      def to_s
        "StatusBarTextMessage: #{@message}, #{@color}"
      end
    end
  end
end
