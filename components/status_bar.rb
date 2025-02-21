# frozen_string_literal: true


require 'glimmer-dsl-libui'
require './services/message_bus'

require_all './data_structures'

module Component
  # status bar component
  class StatusBar
    include Glimmer

    attr_accessor :status_text, :label_color

    def initialize
      @status_text = 'Merge Request Reminder is running in the background'
      @message_bus = Service::MessageBus.instance
      @message_bus.add_observer(self)
      @label_color = :white
    end

    def status_bar
      @area = area(10,10) {
        on_draw do |area_draw_params|
          text {
            string (self.status_text ) { color self.label_color }
          }
        end
      }
    end

    def update(event_message)
      return unless event_message.is_a?(Model::EventMessages::StatusBarTextMessage)

      console_log "Incoming in status bar message #{event_message.message}"

      Glimmer::LibUI.queue_main do
        self.status_text = "Status: #{event_message.message}"
        self.label_color = event_message.color
        @area.redraw
      end
    end

    private

    def console_log(message)
      return unless ENV['OUTPUT_LOG'] == 'true'

      puts "#{Time.now} - #{message}"
    end
  end
end
