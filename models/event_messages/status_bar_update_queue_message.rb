# frozen_string_literal: true

module Model
  module EventMessages
    # settings changed message model used to inform components that the settings have changed
    class StatusBarUpdateQueueMessage
      attr_reader :action, :message, :display_for, :is_priority, :color


      def initialize(message: '', display_for: 5, is_priority: false, color: :white)
        @message = message
        @display_for = display_for
        @is_priority = is_priority
        @color = color
      end

      def to_s
        "StatusBarUpdateQueueMessage: #{@message}, #{@display_for}, #{@is_priority}, #{@color}"
      end
    end
  end
end
