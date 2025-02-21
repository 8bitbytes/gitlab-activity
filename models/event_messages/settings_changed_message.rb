# frozen_string_literal: true

require 'singleton'

module Model
  module EventMessages
    # settings changed message model used to inform components that the settings have changed
    class SettingsChangedMessage

      attr_reader :changes

      private

      def initialize(changes: [{ key: '', value: '' }])
        @changes = changes
      end

      def to_s
        "SettingsChangedMessage: #{@changes}"
      end
    end
  end
end
