#!/usr/bin/env rake
require "bundler/gem_tasks"

task :bundler do
  require "bundler/setup"
end

task :commotion => :bundler do
  require "commotion"
end

task :bump => :commotion do
  v    = Commotion::VERSION.split(".").map( &:to_i )
  v[2] = v[2] + 1
  v    = v.join(".")
  vf   = File.expand_path( "../lib/commotion/version.rb", __FILE__ )
  File.open(vf,"w") do |io|
    io.puts "module Commotion"
    io.puts "  VERSION = '#{v}'"
    io.puts "end"
  end
  puts "git ci -m 'Version bump to #{v}' #{vf}"
end
