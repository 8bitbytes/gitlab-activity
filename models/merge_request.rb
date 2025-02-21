# frozen_string_literal: true

module Model
  class MergeRequest

    attr_accessor :gitlab_user_name, :gitlab_personal_access_token,
                  :check_interval_in_minutes, :force_notification_interval_in_minutes

    def initialize(gitlab_user_name: '', gitlab_personal_access_token: '', check_interval_in_minutes: '5',
                   force_notification_interval_in_minutes: '30')
      @gitlab_user_name = gitlab_user_name
      @gitlab_personal_access_token = gitlab_personal_access_token
      @check_interval_in_minutes = check_interval_in_minutes
      @force_notification_interval_in_minutes = force_notification_interval_in_minutes
    end

    def convert_to_json
      {
        gitlab_user_name: @gitlab_user_name,
        gitlab_personal_access_token: @gitlab_personal_access_token,
        check_interval_in_minutes: @check_interval_in_minutes,
        force_notification_interval_in_minutes: @force_notification_interval_in_minutes
      }.to_json
    end

    def from_json(json)
      settings = JSON.parse(json)
      self.gitlab_user_name = settings['gitlab_user_name']
      self.gitlab_personal_access_token = settings['gitlab_personal_access_token']
      self.check_interval_in_minutes = settings['check_interval_in_minutes']
      self.force_notification_interval_in_minutes = settings['force_notification_interval_in_minutes']
    end
  end
end

