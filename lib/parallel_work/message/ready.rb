module ParallelWork
  class Message
    class Ready < Message

      def name
        "READY"
      end

      def has_payload?
        false
      end

    end
  end
end
