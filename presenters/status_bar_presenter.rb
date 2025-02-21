# frozen_string_literal: true
# typed: false

require './services/message_bus'

module Presenter
  class StatusBarPresenter
    attr_accessor :status_text, :restore_status_text, :text_color, :restore_color

    def initialize
      @message_bus = Service::MessageBus.instance
      @status_text = 'Gitlab Activity is running in the background'
      @restore_status_text = 'Gitlab Activity is running in the background'
      @message_bus = Service::MessageBus.instance
      @message_bus.add_observer(self)
      @text_color = :white
      @restore_color = :white
    end

    def update(event_message)
      return unless event_message.is_a?(Model::EventMessages::StatusBarTextMessage)

      console_log "Incoming in status bar presenter status bar message #{event_message.message}"

      Glimmer::LibUI.queue_main do
        self.status_text = "Status: #{event_message.message}"
      end
    end

    def console_log(message)
      return unless ENV['OUTPUT_LOG'] == 'true'

      puts "#{Time.now} - #{message}"
    end
  end
end
