# frozen_string_literal: true

require './extensions/string'

module Model
  class Settings

    attr_accessor :gitlab_user_name, :gitlab_personal_access_token, :gitlab_url,
                  :check_interval_in_minutes, :force_notification_interval_in_minutes

    def initialize(gitlab_user_name: '', gitlab_personal_access_token: '', gitlab_url: '', check_interval_in_minutes: '5',
                   force_notification_interval_in_minutes: '30')
      @gitlab_user_name = gitlab_user_name
      @gitlab_personal_access_token = gitlab_personal_access_token
      @gitlab_url = gitlab_url
      @check_interval_in_minutes = check_interval_in_minutes
      @force_notification_interval_in_minutes = force_notification_interval_in_minutes
    end

    def convert_to_json
      {
        gitlab_user_name: @gitlab_user_name,
        gitlab_personal_access_token: @gitlab_personal_access_token,
        gitlab_url: @gitlab_url,
        check_interval_in_minutes: @check_interval_in_minutes,
        force_notification_interval_in_minutes: @force_notification_interval_in_minutes
      }.to_json
    end

    def convert_to_encrypted_json
      convert_to_json.encrypt
    end

    def from_json(json)
      settings = JSON.parse(json)
      self.gitlab_user_name = settings['gitlab_user_name']
      self.gitlab_personal_access_token = settings['gitlab_personal_access_token']
      self.gitlab_url = settings['gitlab_url']
      self.check_interval_in_minutes = settings['check_interval_in_minutes']
      self.force_notification_interval_in_minutes = settings['force_notification_interval_in_minutes']
    end

    def ==(other)
      force_notification_interval_in_minutes == other.force_notification_interval_in_minutes &&
        check_interval_in_minutes == other.check_interval_in_minutes &&
        gitlab_personal_access_token == other.gitlab_personal_access_token &&
        gitlab_user_name == other.gitlab_user_name &&
        gitlab_url == other.gitlab_url
    end

    def from_encrypted_json(encrypted_json)
      from_json(encrypted_json.decrypt)
    end
  end
end

