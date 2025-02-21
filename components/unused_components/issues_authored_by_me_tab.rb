=begin
# frozen_string_literal: true

require 'glimmer-dsl-libui'

require './models/issue_list_view_item'
module Component
  # setting model
  class IssuesAuthoredByMeTab
    include Glimmer

    attr_accessor :settings_service, :gitlab_client, :issue_list

    def initialize
      @settings_service = Service::Settings.instance
      @gitlab_client = ::Service::Gitlab.new
      @issue_list = []#build_list_view_array @gitlab_client.open_issues_authored_by_me
    end

    def open_issues_authored_by_me_tab
      tab_item("Open issues created by me"){
        horizontal_box {
          table {
            text_column('Title')
            text_column('Description')
            text_column('Url')
            button_column('Action'){
              on_clicked do |row|
                url = @issue_list[row].url
                `open #{url}`
              end
            }
            cell_rows <= [self, :issue_list, {column_attributes: {'Title' => :title, 'Description' => :description, 'Url' => :url}}]
          }
        }
        button('Reload') {
          stretchy false

          on_clicked do
            self.issue_list = build_list_view_array @gitlab_client.open_issues_authored_by_me
          end
        }
      }
    end

    private

    def build_list_view_array(issue_list)
      @issue_list = issue_list.map do |issue|
        Model::IssueListViewItem.new(title: issue['title'], description: issue['description'], url: issue['web_url'])
      end
    end
  end
end

=end
