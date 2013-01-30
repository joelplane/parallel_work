module ParallelWork
  class Message
    class Work < Message

      def initialize data=nil
        @data = data
      end

      def name
        "WORK"
      end

      def has_payload?
        true
      end

      def payload
        @data
      end

      def payload= data
        @data = data
      end

    end
  end
end
