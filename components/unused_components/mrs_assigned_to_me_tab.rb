=begin
# frozen_string_literal: true

require 'glimmer-dsl-libui'
require 'require_all'
require_all './models/event_messages'
require 'timers'

module Component
  # setting model
  class MrsAssignedToMeTab
    include Glimmer

    attr_accessor :settings_service, :gitlab_client, :mr_list, :timers

    def initialize
      @settings_service = Service::Settings.instance
      @gitlab_client = ::Service::Gitlab.new
      @mr_list = [] #build_list_view_array @gitlab_client.merge_requests_assigned_to_me.map
      #start_monitor
    end

    def mrs_assigned_to_me_tab
      ti = tab_item("MRs assigned to me") {
        horizontal_box {
          table {
            text_column('Title')
            text_column('Description')
            checkbox_column('Approved') {
              editable false
            }
            text_column('Url')
            button_column('Action'){
              on_clicked do |row|
                url = @mr_list[row].url
                `open #{url}`
              end
            }
            cell_rows <= [self, :mr_list, {column_attributes: {'Title' => :title, 'Description' => :description, 'Approved' => :approved, 'Url' => :url}}]
          }
        }
        button('Reload') {
          stretchy false

          on_clicked do
            self.mr_list = build_list_view_array @gitlab_client.merge_requests_assigned_to_me
          end
        }
      }
      puts "ti: #{ti}"
    end

    def update(event_message)
      if event_message.action == Model::EventMessages::SettingsChangedMessage::ACTION
        msg_box(event_message.message, "#{event_message.message}. Reloading settings.")
        start_monitor
      end
    end

    private

    def build_list_view_array(mr_list)
      @mr_list = mr_list.map do |mr|
        approved = @gitlab_client.merge_request_approved_by_me?(mr['project_id'], mr['iid'])
        Model::MergeRequestListViewItem.new(title: mr['title'], description: mr['description'], url: mr['web_url'], approved:)
      end
    end

    def start_monitor
      @timers = Timers::Group.new
      @gitlab_timer = @timers.now_and_every(@settings_service.settings.check_interval_in_minutes.to_i * 60 * 60) do
        self.mr_list = build_list_view_array @gitlab_client.merge_requests_assigned_to_me
      end
    end
  end
end

=end
