require File.expand_path "./parallel_work/version", File.dirname(__FILE__)
require 'socket'
require File.expand_path './parallel_work/runner', File.dirname(__FILE__)
require File.expand_path './parallel_work/messaging', File.dirname(__FILE__)
require File.expand_path './parallel_work/message', File.dirname(__FILE__)

module ParallelWork

  # @param work [#each]
  # @params worker [Fixnum] number of worker processes
  def self.process work, workers, &process_block
    Runner.new(work.each, process_block).spawn(workers).close_other_sockets.start
  end

end
