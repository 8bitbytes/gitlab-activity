# frozen_string_literal: true

module Model
  class MergeRequestListViewItem

    attr_accessor :title, :description, :url, :approved, :status

    def initialize(title: '', description: '', url: '', status: '', approved: false)
      @title = title
      @description = description
      @url = url
      @approved = approved
      @status = status
    end

    def action
      'View Merge Request'
    end
  end
end

