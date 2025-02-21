# frozen_string_literal: true
# typed: false

require 'glimmer-dsl-libui'

require './services/message_bus'
require './services/application'
require './services/settings'

module Presenter
  class SettingsPresenter
    include Glimmer::LibUI::CustomWindow

    attr_accessor :settings_service, :show_pac, :enable_save_settings_button, :refresh
    attr_reader :tab_id

    def initialize
      @settings_service = Service::Settings.instance
      @show_pac = false
      @enable_save_settings_button = false
      @message_bus = Service::MessageBus.instance
      @message_bus.add_observer(self)
      @tab_id = 'settings'
    end

    def handle_value_change(key, value)
      console_log "Changing #{key} to #{value}"
      @settings_service.settings.instance_variable_set("@#{key}", value)
      handle_settings_change
    end

    def fetch_value(key)
      @settings_service.settings.send(key)
    end

    def handle_show_pac_change
      self.show_pac = !show_pac
    end

    def save_settings
      return unless settings_service.settings_changed?

      @settings_service.save_settings
      @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: 'Settings Saved!',
                                                                                             display_for: 1, is_priority: true, color: :green))

      show_default_status
    end

    def on_load
      @message_bus.publish_message(message: Model::EventMessages::CtaButtonMessage.new(button_text: 'Save Settings', callback: method(:save_settings)))
      handle_settings_change
      @message_bus.publish_message(message: Model::EventMessages::TabChangeEventMessage.new(tab_id: @tab_id))
    end

    def update(event_message)
      return unless event_message.is_a?(Model::EventMessages::SettingsChangedMessage)

      event_message.changes.each do |change|
        case change[:key]
        when 'gitlab_user_name'
        when 'gitlab_personal_access_token'
        when 'gitlab_url'
          msg_box('Gitlab Activity', 'Application will now restart to apply changes')
          Service::Application.new.restart
        end
      end
    end
    private

    def handle_settings_change
      settings_have_changed = @settings_service.settings_changed?
      @enable_save_settings_button = settings_have_changed

      if settings_have_changed
        console_log 'Sending settings changed message'
        show_changes_pending_status
      else
        console_log 'Sending default settings status message'
        show_default_status
      end
    end

    def show_default_status
      status_bar_text = 'Settings loaded'
      status_bar_text_color = :white

      unless @settings_service.valid?
        status_bar_text = "Settings are not valid - #{@settings_service.load_error_message}"
        status_bar_text_color = :red
      end

      @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: status_bar_text, color: status_bar_text_color,
                                                                                                  display_for: 0, is_priority: true))
    end

    def show_changes_pending_status
      @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: 'Settings have changed',
                                                                                                  display_for: 0,
                                                                                                  color: :red))
    end

    def console_log(message)
      return unless ENV['OUTPUT_LOG'] == 'true'

      puts "#{Time.now} - #{message}"
    end
  end
end
