# frozen_string_literal: true
# typed: false

require './services/message_bus'
require './services/gitlab'
require './models/merge_request_list_view_item'
require_relative 'presenter_base'

module Presenter
  class MrsAuthoredByMePresenter < Presenter::PresenterBase
    attr_accessor :mr_list, :on_request_update, :on_load, :title_text, :status_text, :status_area, :countdown_area, :reload_countdown_text, :mr_table
    attr_reader :should_publish_on_load, :tab_id, :is_tab_active

    def initialize
      @message_bus = Service::MessageBus.instance
      @message_bus.add_observer(self)
      @gitlab_service = Service::Gitlab.new(on_error: method(:on_gitlab_error))
      @settings_service = Service::Settings.instance
      @title_text = 'Mrs Authored By Me'
      @mr_list = []
      @status_area = nil
      @countdown_area = nil
      @reloading_in = -1
      @should_publish_on_load = true
      @tab_id = 'mrs_authored_by_me'
      @is_tab_active = true
      @mr_table = nil
      # @status_color = :white
      fetch_mr_list
    end

    def fetch_mr_list(silent: false)
      @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: 'Fetching merge request!', display_for: 1)) unless silent
      @mr_list = build_list_view_array @gitlab_service.merge_requests_authored_by_me
      @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: 'Merge request list updated!', display_for: 1)) unless silent
      refresh_status_area if @is_tab_active
      refresh_mr_table
    end

    def on_load
      return unless @should_publish_on_load

      @message_bus.publish_message(message: Model::EventMessages::CtaButtonMessage.new(button_text: 'Reload', callback: method(:fetch_mr_list)))
      @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: 'Merge requests authored by me loaded', display_for: 0, is_priority: true))
      @message_bus.publish_message(message: Model::EventMessages::TabChangeEventMessage.new(tab_id: @tab_id))
    end

    def update(message)
      if message.is_a?(Model::EventMessages::ForceReloadMessage)
        console_log 'force reload of mrs authored by me'
        fetch_mr_list silent: true
      end

      if message.is_a?(Model::EventMessages::CountdownUpdateMessage)
        @reloading_in = message.time_remaining
        @should_publish_on_load = false if @is_tab_active
        refresh_status_area
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

    def status_text
      return invalid_settings_status_text unless @settings_service.valid?
      return invalid_gitlab_credentials_status_text unless @gitlab_service.valid?

      @@status_color  = :white

      if mr_list.empty?
        @status_text = "You have not authored any merge requests."
      else
        @status_text = "You authored #{mr_list.size} merge request#{mr_list.size == 1 ? '' : 's'}. #{mr_list.select { |mr| mr.approved }.count} of them are approved."
      end
    end

    private

    def on_gitlab_error(error)
      @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: error, display_for: 10, color: :red))
    end

    def refresh_status_area
      return if @status_area.nil?

      @status_area.redraw
    end

    def refresh_countdown_area
      return if @countdown_area.nil?

      @countdown_area.redraw
    end

    def refresh_mr_table
      return if @mr_table.nil?

      @mr_table.cell_rows = @mr_list
    end

    def build_list_view_array(mr_list)
      @mr_list = mr_list.map do |mr|
        approved = @gitlab_service.merge_request_approved?(mr['project_id'], mr['iid'])
        Model::MergeRequestListViewItem.new(title: mr['title'], description: mr['description'],status: mr['merge_status'], url: mr['web_url'], approved:)
      end
    end

    def console_log(message)
      return unless ENV['OUTPUT_LOG'] == 'true'

      puts "#{Time.now} - #{message}"
    end
  end
end
