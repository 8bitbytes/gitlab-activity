# frozen_string_literal: true

require 'glimmer-dsl-libui'

require './models/issue_list_view_item'
module Component
  # setting model
  class CtaButton
    include Glimmer

    attr_accessor :message_bus, :callback, :button_text

    def initialize
      @message_bus = Service::MessageBus.instance
      @message_bus.add_observer(self)
      @button_text = 'Click me'
      @callback = nil
    end

    def update(event_message)
      return unless event_message.is_a?(Model::EventMessages::CtaButtonMessage)

      self.button_text = event_message.button_text
      self.callback = event_message.callback
    end

    def create
      button() {
        text <= [self, :button_text]
        on_clicked do
          callback.call unless callback.nil?
        end
      }
    end

  end
end

