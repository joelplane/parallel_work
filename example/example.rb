require File.expand_path "../lib/parallel_work", File.dirname(__FILE__)

work = (1..10).to_a

ParallelWork.process work, 4 do |data|
  puts data
  sleep 1
end
