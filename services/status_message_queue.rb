# frozen_string_literal: true

require './services/message_bus'
require 'singleton'

require_all './data_structures'

module Service
  # Class for managing status messages
  class StatusMessageQueue
    include Singleton

    def initialize
      @message_bus = Service::MessageBus.instance
      @message_bus.add_observer(self)
      @message_queue = DataStructures::Stack.new
      @queue_processing = false
      @mutex = Mutex.new
      @current_status_text = ''
    end

    def update(event_message)
      return unless event_message.is_a?(Model::EventMessages::StatusBarUpdateQueueMessage)

      @mutex.synchronize do
        @message_queue.push! event_message
        process_queue unless @queue_processing
      end
    end

    def process_queue
      return if @queue_processing

      @queue_processing = true

      Thread.new do
        until @message_queue.empty?
          message = nil
          @mutex.synchronize do
            message = @message_queue.pop!
          end

          next if message.nil?

          process_message(message)
        end
        @queue_processing = false
      end
    end

    private

    attr_accessor :current_status_text

    def process_message(event_message)
      if event_message.display_for.positive?
        process_timeout_message event_message
      else
        console_log "Processing message: #{event_message.message}"
        self.current_status_text = event_message.message
        send_status_bar_text_message(message: event_message.message, color: event_message.color)
      end
    end

    def process_timeout_message(event_message)
      console_log "Processing message with timeout: #{event_message.message}"
      send_status_bar_text_message(message: event_message.message, color: event_message.color)
      sleep event_message.display_for
      send_status_bar_text_message(message: current_status_text, color: :white) # TODO: store last color and use it here
    end

    def console_log(message)
      return unless ENV['OUTPUT_LOG'] == 'true'

      puts "#{Time.now} - #{message}"
    end

    def send_status_bar_text_message(message: '', color: :white)
      Glimmer::LibUI.queue_main do
        @message_bus.publish_message(message: Model::EventMessages::StatusBarTextMessage.new(message: message,
                                                                                             color: color))
      end
    end
  end
end
