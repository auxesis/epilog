#!/usr/bin/env ruby
#
# aggregator.rb
# Reads log files and pops them into a database.

require 'lib/colours'
require 'lib/http'
require 'lib/watcher'

# let's begin

if ARGV.length < 1 then
  puts "Usage: aggregator.rb <file> [interval]"
  exit 1
end

# get the filename
filename = ARGV[0]

# determine the interval
interval = ARGV[1] || 2
interval = interval.to_i

# setup database storage 
storage = Epilog::HttpStorage.new

# setup watcher
watcher = Epilog::Watcher.new(storage)

# FIXME maybe daemonize correctly?
begin
  # watch indefinitely
  watcher.watch(filename, interval)
rescue Interrupt
  puts "Exiting.".magenta
end

