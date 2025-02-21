# frozen_string_literal: true

module DataStructures
  # Implementation of a simple queue FIFO
  class Queue

    attr_reader :queue

    def initialize
      @queue = []
    end

    def push!(value)
      @queue << value
    end

    def pop!
      return nil if @queue.empty?

      val = @queue.first
      @queue.delete_at(0)
      val
    end

    def peek
      return nil if @queue.empty?

      @queue.first
    end
  end
end
