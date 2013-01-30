require File.expand_path "../lib/parallel_work", File.dirname(__FILE__)

work = (1..400).to_a

ParallelWork.process work, 40 do |data|
  puts data
  sleep rand
end
