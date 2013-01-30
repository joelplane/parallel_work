module ParallelWork
  class Runner

    SOCKET_MAX_LEN = 1000
    MESSAGE_LEN = 5

    # @param work [#next]
    def initialize work, process_block
      @work = work
      @process_block = process_block
      @master = nil
      @parent_sockets = []
    end

    def setup_sockets
      @child_socket, parent_socket = Socket.pair("AF_UNIX", "SOCK_DGRAM", 0)
      @parent_sockets << parent_socket
    end

    def spawn n_workers
      setup_sockets

      child_pid = fork
      if child_pid
        if n_workers == 1
          @master = true
        else
          @master = false
          spawn n_workers - 1
        end
      else
        @master = false
      end

      self
    end

    def close_other_sockets
      if @master
        @child_socket.close
      else
        @parent_sockets.each do |socket|
          socket.close
        end
      end
      self
    end

    def start
      if @master
        puts "master pid #{Process.pid}"
        its_over = false
        while !@parent_sockets.empty? && (ready = IO.select(@parent_sockets))
          socket = ready[0][0]
          message_from_worker = Messaging.recv socket
          send_quit = lambda do |socket|
            Messaging.send socket, Message::Quit.new
            socket.close
          end
          begin
            if its_over
              send_quit[socket]
            else
              Messaging.send socket, Message::Work.new(@work.next)
            end
          rescue StopIteration
            its_over = true
            send_quit[socket]
          end
          @parent_sockets = @parent_sockets.reject{|s|s.closed?}
        end
      else
        puts "child pid #{Process.pid}"
        Messaging.send @child_socket, Message::Ready.new
        while (message = Messaging.recv @child_socket)
          case message
            when Message::Work
              @process_block.call(message.payload)
              Messaging.send(@child_socket, Message::Ready.new)
            when Message::Quit
              exit 0
            else
              raise "unknown message #{message}"
          end
        end
      end
    end

  end
end
