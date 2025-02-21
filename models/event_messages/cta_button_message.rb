# frozen_string_literal: true

require 'singleton'

module Model
  module EventMessages
    # settings changed message model used to inform components that the settings have changed
    class CtaButtonMessage
      attr_reader :button_text, :callback

      def initialize(button_text: '', callback: nil)
        @button_text = button_text
        @callback = callback
      end

      def to_s
        "CtaButtonMessage: #{@button_text}"
      end
    end
  end
end
