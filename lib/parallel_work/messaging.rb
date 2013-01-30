module ParallelWork
  class Messaging

    MESSAGE_TYPE_LENGTH = 5

    # @param [Socket]
    # @param [ParallelWork::Message]
    # @return [void]
    def self.send socket, message
      Sending.send socket, message
    end

    # @param [Socket]
    # @return [ParallelWork::Message]
    def self.recv socket
      Receiving.recv socket
    end

    private

    class Sending

      def self.send socket, message
        new(socket, message).send_message
      end

      def initialize socket, message
        @socket = socket
        @message = message
      end

      def send_message
        send_message_type
        if @message.has_payload?
          send_payload_length
          send_payload
        end
      end

      private

      def send_message_type
        send "%#{MESSAGE_TYPE_LENGTH}s" % @message.name
      end

      # payload length sent as 32 bit int.
      def send_payload_length
        send [marshalled_payload.length].pack('l')
      end

      def send_payload
        send marshalled_payload
      end

      def send data
        @socket.send(data, 0)
      end

      def marshalled_payload
        @marshalled_payload ||= Marshal.dump(@message.payload)
      end

    end

    class Receiving

      def self.recv socket
        new(socket).recv_message
      end

      def initialize socket
        @socket = socket
      end

      def recv_message
        message_type = recv_message_type.strip
        message = build_message message_type
        if message.has_payload?
          payload_length = recv_payload_length
          marshalled_payload = recv_payload payload_length
          unmarshalled_payload = unmarshall_payload marshalled_payload
          message.payload = unmarshalled_payload
        end
        message
      end

      private

      def recv_message_type
        @socket.recv(MESSAGE_TYPE_LENGTH)
      end

      def build_message message_type
        Message.build(message_type)
      end

      def recv_payload_length
        data = @socket.recv(4)
        data.unpack('l')[0]
      end

      def recv_payload payload_length
        @socket.recv(payload_length)
      end

      def unmarshall_payload marshalled_payload
        Marshal.load(marshalled_payload)
      end

    end

  end
end
