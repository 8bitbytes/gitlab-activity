=begin
# frozen_string_literal: true

require 'glimmer-dsl-libui'
require './models/merge_request_list_view_item'

module Component
  # setting model
  class MrsAuthoredByMeTab
    include Glimmer

    attr_accessor :settings_service, :gitlab_client, :mr_list

    attr_reader :gitlab_timer

    def initialize
      @settings_service = Service::Settings.instance
      @gitlab_client = ::Service::Gitlab.new
      @mr_list = []#build_list_view_array @gitlab_client.merge_requests_authored_by_me.map
    end

    def mrs_authored_by_me_tab
      tab_item("MRs authored by me"){
        horizontal_box {
          table {
            text_column('Title')
            text_column('Description')
            checkbox_column('Approved') {
              editable false
            }
            text_column('Status')
            text_column('Url')
            column_action_button
            cell_rows <= [self, :mr_list, {column_attributes: {'Title' => :title, 'Description' => :description, 'Approved' => :approved, 'Status' => :status,  'Url' => :url}}]
          }
        }
        button('Reload') {
          stretchy false

          on_clicked do
            self.mr_list = build_list_view_array @gitlab_client.merge_requests_authored_by_me
          end
        }
      }
    end

    private

    def interval_in_seconds
      @settings_service.check_interval_in_minutes.to_i * 60
    end

    def column_action_button
      button_column('Action'){
        on_clicked do |row|
          url = @mr_list[row].url
          `open #{url}`
        end
      }
    end

    def build_list_view_array(mr_list)
      @mr_list = mr_list.map do |mr|
        approved = @gitlab_client.merge_request_approved?(mr['project_id'], mr['iid'])
        Model::MergeRequestListViewItem.new(title: mr['title'], description: mr['description'],status: mr['merge_status'], url: mr['web_url'], approved:)
      end
    end
  end
end

=end
