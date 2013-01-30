# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "parallel_work/version"

Gem::Specification.new do |s|
  s.name        = "parallel_work"
  s.version     = ParallelWork::VERSION
  s.authors     = ["Joel Plane"]
  s.email       = ["joel.plane@gmail.com"]
  s.homepage    = "https://github.com/joelplane/parallel_work"
  s.summary     = %q{Spread work over multiple processes}
  s.description = %q{When work is in a simple queue, this library allows easily spreading the work over multiple processes on the same server communicating with UNIX sockets. Only tested on Ruby 1.8.7 (REE)}

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
