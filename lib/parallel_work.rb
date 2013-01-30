require File.expand_path "./parallel_work/version", File.dirname(__FILE__)
require 'socket'

module ParallelWork

  # @param work [#each]
  # @params worker [Fixnum] number of worker processes
  def self.process work, workers, &process_block
    Work.new(work.each, process_block).spawn(workers).close_other_sockets.start
  end

  class Work

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
          message_from_worker = socket.recv(MESSAGE_LEN)
          send_quit = lambda do |socket|
            socket.send('QUIT ', 0)
            socket.close
          end
          begin
            if its_over
              send_quit[socket]
            else
              data = @work.next
              socket.send('WORK ', 0)
              socket.send(Marshal.dump(data), 0)
            end
          rescue StopIteration
            its_over = true
            send_quit[socket]
          end
          @parent_sockets = @parent_sockets.reject{|s|s.closed?}
        end
      else
        puts "child pid #{Process.pid}"
        @child_socket.send('READY', 0)
        while message = @child_socket.recv(MESSAGE_LEN)
          if message.strip == 'WORK'
            marshalled_data = @child_socket.recv(SOCKET_MAX_LEN)
            data = Marshal.load(marshalled_data)
            @process_block.call(data)
            @child_socket.send('OK   ', 0)
          elsif message.strip == 'QUIT'
            exit 0
          else
            raise "unknown message #{message}"
          end
        end
      end
    end

  end

end
