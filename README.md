parallel_work
===========

Spread work over multiple processes on the same server, with a central work queue.

## Installation

    gem install parallel_work

## Example Usage

```ruby
require "parallel_work"

work = (1..400).to_a

ParallelWork.process work, 8 do |data|
  puts data
  sleep rand
end

```