# frozen_string_literal: true

module DataStructures
  # implementation of a stack LIFO
  class Stack

    attr_reader :stack

    def initialize
      @stack = []
    end

    def push!(value)
      @stack << value
    end

    def pop!
      return nil if @stack.empty?

      val = @stack.last
      @stack.delete_at(@stack.length - 1)
      val
    end

    def peek
      return nil if @stack.empty?

      @stack.last
    end

    def empty?
      @stack.empty?
    end

  end
end
