require File.expand_path "./parallel_work/version", File.dirname(__FILE__)
require 'socket'

module ParallelWork

  # @param work [#each]
  # @params worker [Fixnum] number of worker processes
  def self.process work, workers, &process_block
    Work.new(work.each, process_block).spawn(workers).start
  end

  class Work

    SOCKET_MAX_LEN = 1000
    MESSAGE_LEN = 5

    # @param work [#next]
    def initialize work, process_block
      @work = work
      @process_block = process_block
      @master = true
    end

    def spawn n_workers
      @child_socket, @parent_socket = Socket.pair("AF_UNIX", "SOCK_DGRAM", 0)

      child_pid = fork
      if child_pid.nil?
        @master = true
        @child_socket.close
      else
        @master = false
        @parent_socket.close
      end

      self
    end

    def start
      if @master
        puts "master start"
        while @parent_socket.recv(MESSAGE_LEN)
          begin
          data = @work.next
            @parent_socket.send('WORK ', 0)
            @parent_socket.send(Marshal.dump(data), 0)
          rescue StopIteration
            @parent_socket.send('QUIT ', 0)
            exit 0
          end
        end
      else
        puts "child start"
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
