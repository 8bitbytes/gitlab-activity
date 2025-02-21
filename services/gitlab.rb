# frozen_string_literal: true

require 'faraday'

module Service
  # Class for communicating with Gitlab
  class Gitlab
    def initialize(on_error: nil)
      @settings = Service::Settings.instance
      @on_error = on_error
      @valid = true
    end

    def merge_requests_assigned_to_me
      return [] if no_fetch

      @valid = true
      # get merge requests assigned to me from Gitlab
      response = Faraday.get(merge_requests_assigned_to_me_url) do |req|
        req.headers = authorization_headers
      end

      handle_error_response(response.status) if response.status != 200
      return [] if response.status != 200

      console_log response.body
      JSON.parse(response.body)

    rescue StandardError => e
      @valid = false
      @on_error&.call(e.message)
      return []
    end

    def merge_requests_authored_by_me
      return [] if no_fetch

      @valid = true
      # get merge requests authored by me from Gitlab
      response = Faraday.get(merge_requests_authored_by_me_url) do |req|
        req.headers = authorization_headers
      end

      handle_error_response(response.status) if response.status != 200
      return [] if response.status != 200

      console_log response.body
      JSON.parse(response.body)

    rescue StandardError => e
      @valid = false
      @on_error&.call(e.message)
      return []
    end

    def merge_request_approved_by_me?(project_id, merge_request_id )
      return false if no_fetch

      response = Faraday.get(merge_request_approval_url(project_id, merge_request_id)) do |req|
        req.headers = authorization_headers
      end

      handle_error_response(response.status) if response.status != 200
      return false if response.status != 200

      console_log response.body
      approvals = JSON.parse(response.body)
      approvals['approved_by'].any? { |approver| approver['user']['username'] == @settings.settings.gitlab_user_name }
    end

    def merge_request_approved?(project_id, merge_request_id)
      return false if no_fetch

      response = Faraday.get(merge_request_approval_url(project_id, merge_request_id)) do |req|
        req.headers = authorization_headers
      end

      handle_error_response(response.status) if response.status != 200
      return false if response.status != 200

      console_log response.body
      approvals = JSON.parse(response.body)
      approvals['approved_by'].any?
    end

    def open_issues_assigned_to_me
      return [] if no_fetch

      @valid = true
      # get merge requests assigned to me from Gitlab
      response = Faraday.get(issues_assigned_to_me_url) do |req|
        req.headers = authorization_headers
      end

      handle_error_response(response.status) if response.status != 200
      return [] if response.status != 200

      console_log response.body
      JSON.parse(response.body)

    rescue StandardError => e
      @valid = false
      @on_error&.call(e.message)
      return []
    end

    def open_issues_authored_by_me
      return [] if no_fetch

      @valid = true
      # get merge requests assigned to me from Gitlab
      response = Faraday.get(issues_authored_by_me_url) do |req|
        req.headers = authorization_headers
      end

      handle_error_response(response.status) if response.status != 200
      return [] if response.status != 200

      console_log response.body
      JSON.parse(response.body)

    rescue StandardError => e
      @valid = false
      @on_error&.call(e.message)
      return []
    end

    def valid?
      @valid
    end

    private

    def issues_authored_by_me_url
      "https://#{@settings.settings.gitlab_url}/api/v4/issues?author_username=#{@settings.settings.gitlab_user_name}&state=opened"
    end

    def issues_assigned_to_me_url
      "https://#{@settings.settings.gitlab_url}/api/v4/issues?assignee_username=#{@settings.settings.gitlab_user_name}&state=opened"
    end

    def merge_requests_assigned_to_me_url
      "https://#{@settings.settings.gitlab_url}/api/v4/merge_requests?reviewer_username=#{@settings.settings.gitlab_user_name}&state=opened&scope=all"
    end

    def merge_requests_authored_by_me_url
      "https://#{@settings.settings.gitlab_url}/api/v4/merge_requests?author_username=#{@settings.settings.gitlab_user_name}&state=opened&scope=all"
    end

    def merge_request_approval_url(project_id, merge_request_id)
      "https://#{@settings.settings.gitlab_url}/api/v4/projects/#{project_id}/merge_requests/#{merge_request_id}/approvals"
    end

    def authorization_headers
      { 'Authorization' => "Bearer #{@settings.settings.gitlab_personal_access_token}" }
    end

    def no_fetch
      ENV['NO_FETCH'] == 'true'
    end

    def console_log(message)
      return unless ENV['OUTPUT_LOG'] == 'true'

      puts "#{Time.now} - #{message}"
    end

    def handle_error_response(status_code)
      error_message = case status_code
      when 401
        'Unauthorized. Check your personal access token.'
      when 404
        'Not found. Check your Gitlab URL.'
      else
        "Error: #{status_code}"
      end

      @valid = false
      console_log("Error fetching from gitlab #{error_message})")

      @on_error&.call(error_message)
    end
  end
end
