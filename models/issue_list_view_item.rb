# frozen_string_literal: true

module Model
  class IssueListViewItem

    attr_accessor :title, :description, :url, :approved

    def initialize(title: '', description: '', url: '')
      @title = title
      @description = description
      @url = url
    end

    def action
      'View Issue'
    end
  end
end

