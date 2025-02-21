# frozen_string_literal: true
# typed: false

module Presenter
  class PresenterBase

    def initialize
      @settings_service = Service::Settings.instance
      @gitlab_service = Service::Gitlab.new
    end

    @@status_color = :white

    def invalid_settings_status_text
      @@status_color = :red
      'Invalid settings. Please update gitlab token and username in settings'
    end

    def invalid_gitlab_credentials_status_text
      @@status_color = :red
      'Unable to connect to gitlab with provided settings'
    end

    def status_color
      @@status_color
    end

    def services_healthy?
      return false unless @gitlab_service.valid? && @settings_service.valid?

      true
    end

    def reload_countdown_text
      return '' if @reloading_in == -1
      return '' unless services_healthy?

      "Reloading in #{Time.at(@reloading_in.to_i).utc.strftime("%H:%M:%S")}"
    end
  end
end
