# frozen_string_literal: true

require 'singleton'
require 'models/issue_list_view_item'
require 'models/merge_request_list_view_item'

module Service
  # Class for generating list view items for various tables
  class ListViewItemGenerator
    include Singleton

    def generate_mr_list_view_items(mr_list: [])
      mr_list.map do |mr|
        approved = @gitlab_client.merge_request_approved?(mr['project_id'], mr['iid'])
        Model::MergeRequestListViewItem.new(title: mr['title'], description: mr['description'],
                                            status: mr['merge_status'], url: mr['web_url'], approved: approved)
      end
    end

    def generate_issue_list_view_items(issue_list: [])
      issue_list.map do |issue|
        Model::IssueListViewItem.new(title: issue['title'], description: issue['description'], url: issue['web_url'])
      end
    end
  end
end
