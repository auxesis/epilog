#!/usr/bin/env ruby
#
# logfeeder.rb
#
# reads a specified file and outputs it in delayed chunks
#

if ARGV.length < 1
  puts "Usage: logfeeder.rb <input>"
  exit 1
end

File.open(ARGV[0]) do |file|
    lines = file.readlines
    lines.each do |line|
      $stdout.write line
      $stdout.flush
      sleep rand # * 2 
    end
end

