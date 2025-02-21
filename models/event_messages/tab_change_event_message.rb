

module Model
  module EventMessages
    # settings changed message model used to inform components that the settings have changed
    class TabChangeEventMessage
      attr_reader :tab_id


      def initialize(tab_id: '')
        @tab_id = tab_id
      end

      def to_s
        "TabChangeEventMessage: #{@tab_id}"
      end
    end
  end
end
