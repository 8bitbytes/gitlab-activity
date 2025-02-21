# frozen_string_literal: true

module Model
  # event message model used to pass messages between components
  class EventMessage

    attr_reader :action, :message

    def initialize(action: '', message: '')
      @action = action
      @message = message
    end
  end
end
