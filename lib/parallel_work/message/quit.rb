module ParallelWork
  class Message
    class Quit < Message

      def name
        "QUIT"
      end

      def has_payload?
        false
      end

    end
  end
end
