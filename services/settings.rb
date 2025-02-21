# frozen_string_literal: true

require './models/settings'
require './services/message_bus'
require 'require_all'
require_all './models/event_messages'
require 'singleton'
require 'observer'

module Service
  # Settings class to load and save settings to file
  class Settings
    include Singleton


    attr_accessor :settings, :gitlab_user_name, :gitlab_personal_access_token, :check_interval_in_minutes,
                  :force_notification_interval_in_minutes

    attr_reader :snapshot, :message_bus, :load_error_message

    def initialize
      @settings = Model::Settings.new(gitlab_user_name: @gitlab_user_name,
                                      gitlab_personal_access_token: @gitlab_personal_access_token,
                                      gitlab_url: @gitlab_url,
                                      check_interval_in_minutes: @check_interval_in_minutes,
                                      force_notification_interval_in_minutes: @force_notification_interval_in_minutes)

      @load_error_message = ''
      @message_bus = Service::MessageBus.instance
      load_settings
      @snapshot = @settings.dup
    end

    def load_settings
      if File.exist?('settings.env')
        file_content = File.read('settings.env')
        @settings.from_encrypted_json(file_content)
      else
        @load_error_message = 'Setting file not found'
        @message_bus.publish_message(message: Model::EventMessages::MessageBoxMessage.new(message_text: settings_message))
        use_default_settings
      end
    rescue JSON::ParserError
      puts 'Error parsing settings.json file. Using default settings.'
      @load_error_message = 'Error parsing settings.json file.'
      use_default_settings
    end

    def save_settings
      # save settings to file
      File.open('settings.env', 'w') do |f|
        f.write(@settings.convert_to_encrypted_json)
      end

      notify_change
      @snapshot = @settings.dup
    end

    def valid?
      return false if @settings == default_settings

      if missing_key
        @load_error_message = 'Missing key(s) in settings'
        return false
      end


      true
    end

    def default_settings
      Model::Settings.new(gitlab_user_name: 'johndoe', gitlab_personal_access_token: '123456', gitlab_url: 'git.site.com',
                                      check_interval_in_minutes: '5', force_notification_interval_in_minutes: '30')
    end

    def use_default_settings
      @settings = default_settings
    end

    def missing_key
      return true if @settings.gitlab_url&.empty?
      return true if @settings.gitlab_user_name&.empty?
      return true if @settings.gitlab_personal_access_token&.empty?
      return true if @settings.check_interval_in_minutes&.empty?
      return true if @settings.force_notification_interval_in_minutes&.empty?

     false
    end

    def settings_changed?
      @snapshot != @settings
    end

    def notify_change
      return unless settings_changed?

      changes = []

      if @snapshot.gitlab_user_name != @settings.gitlab_user_name
        changes.push(key: 'gitlab_user_name', value: @settings.gitlab_user_name)
      end

      if @snapshot.gitlab_personal_access_token != @settings.gitlab_personal_access_token
        changes.push(key: 'gitlab_personal_access_token', value: @settings.gitlab_personal_access_token)
      end

      if @snapshot.gitlab_url != @settings.gitlab_url
        changes.push(key: 'gitlab_url', value: @settings.gitlab_url)
      end

      if @snapshot.check_interval_in_minutes != @settings.check_interval_in_minutes
        changes.push(key: 'check_interval_in_minutes', value: @settings.check_interval_in_minutes)
      end

      if @snapshot.force_notification_interval_in_minutes != @settings.force_notification_interval_in_minutes
        changes.push(key: 'force_notification_interval_in_minutes', value: @settings.force_notification_interval_in_minutes)
      end

      @message_bus.publish_message(message: Model::EventMessages::SettingsChangedMessage.new(changes: changes))
    end

    def settings_message
      'Settings not found. Please enter your Gitlab user name and personal access token in the settings tab.'
    end
  end
end

