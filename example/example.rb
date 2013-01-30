require File.expand_path "../lib/parallel_work", File.dirname(__FILE__)

# Turn on REE copy-on-write GC if we're running on REE
GC.copy_on_write_friendly = true if GC.respond_to? :copy_on_write_friendly?

work = (1..400).to_a

ParallelWork.process work, 8 do |data|
  puts data
  sleep rand
end
