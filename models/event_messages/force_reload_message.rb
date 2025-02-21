

module Model
  module EventMessages
    # settings changed message model used to inform components that the settings have changed
    class ForceReloadMessage
      attr_reader :message


      def initialize
        @message = 'Force Reload'
      end

      def to_s
        "ForceReloadMessage: #{@message}"
      end
    end
  end
end
