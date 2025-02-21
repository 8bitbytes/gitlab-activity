# frozen_string_literal: true
# typed: false

require './services/message_bus'
require './services/gitlab'
require './models/issue_list_view_item'

module Presenter
  class IssuesAssignedToMePresenter < Presenter::PresenterBase
    attr_accessor :issue_list, :on_request_update, :on_load, :title_text, :area, :should_publish_on_load, :issue_table
    attr_reader :tab_id, :is_tab_active

    def initialize
      @message_bus = Service::MessageBus.instance
      @message_bus.add_observer(self)
      @gitlab_service = Service::Gitlab.new
      @settings_service = Service::Settings.instance
      @title_text = 'Issues Assigned To Me'
      @issue_list = []
      @area = nil
      @should_publish_on_load = true
      @tab_id = 'issues_assigned_to_me'
      @is_tab_active = true
      @issue_table = nil
      fetch_issue_list
    end

    def fetch_issue_list(silent: false)
      @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: 'Fetching issues!', display_for: 1)) unless silent
      @issue_list = build_list_view_array @gitlab_service.open_issues_assigned_to_me
      @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: 'Issue list updated!', display_for: 1)) unless silent
      refresh_area if @is_tab_active
      refresh_issue_table
    end

    def update(message)
      if message.is_a?(Model::EventMessages::ForceReloadMessage)
        console_log 'force reload of issues assigned to me'
        fetch_issue_list silent: true
      end

      if message.is_a?(Model::EventMessages::CountdownUpdateMessage)
        @reloading_in = message.time_remaining
        @should_publish_on_load = false if @is_tab_active
        refresh_area
      end

      if message.is_a?(Model::EventMessages::TabChangeEventMessage)
        if message.tab_id != @tab_id
          @is_tab_active = false
          @should_publish_on_load = true
        else
          @is_tab_active = true
        end
      end
    end

    def on_load
      return unless @should_publish_on_load

      @message_bus.publish_message(message: Model::EventMessages::CtaButtonMessage.new(button_text: 'Reload', callback: method(:fetch_issue_list)))
      @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: 'Issues assigned to me loaded', display_for: 0, is_priority: true))
      @message_bus.publish_message(message: Model::EventMessages::TabChangeEventMessage.new(tab_id: @tab_id))
    end

    def status_text
      return invalid_settings_status_text unless @settings_service.valid?
      return invalid_gitlab_credentials_status_text unless @gitlab_service.valid?

      @@status_color  = :white

      @status_text = if issue_list.empty?
                       'You have no issues assigned to you.'
                     else
                       "You have #{issue_list.size} issue#{issue_list.size == 1 ? '' : 's'} assigned to you."
                     end
    end

    private

    def refresh_area
      return if @area.nil?

      @area.redraw
    end

    def refresh_issue_table
      return if @issue_table.nil?

      @issue_table.cell_rows = @issue_list
    end

    def build_list_view_array(issue_list)
      @issue_list = issue_list.map do |issue|
        Model::IssueListViewItem.new(title: issue['title'], description: issue['description'], url: issue['web_url'])
      end
    end

    def console_log(message)
      return unless ENV['OUTPUT_LOG'] == 'true'

      puts "#{Time.now} - #{message}"
    end
  end
end
