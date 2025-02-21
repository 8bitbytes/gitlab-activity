
module Model
  module EventMessages
    # settings changed message model used to inform components that the settings have changed
    class CountdownUpdateMessage
      attr_reader :time_remaining


      def initialize(time_remaining)
        @time_remaining = time_remaining
      end

      def to_s
        "CountdownUpdateMessage: #{@time_remaining}"
      end
    end
  end
end
