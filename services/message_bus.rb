# frozen_string_literal: true

require 'observer'
require 'singleton'

module Service
  # message bus used to publish messages to subscribers
  class MessageBus
    include Observable
    include Singleton

    def publish_message(message:)
      console_log message
      changed
      notify_observers message
    end

    def console_log(message)
      return unless ENV['OUTPUT_LOG'] == 'true'

      return unless ENV['LOG_COUNTDOWN'] == 'true' || !message.is_a?(Model::EventMessages::CountdownUpdateMessage)

      puts "#{Time.now} - Publishing message: #{message}"
    end
  end
end
