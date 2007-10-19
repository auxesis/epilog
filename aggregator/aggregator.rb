#!/usr/bin/env ruby
#
# aggregator.rb
# Reads log files and pops them into a database.
#
# Dates and times are converted hackishly to datetime objects 
# so date searches in the app are remotely possible.
#
# An md5sum of the intact line is used as a unique identifier 
# so duplicates are handled nicer. 
#
# The data is indexed by ferret, though all fields seem to have
# to be indexed to get the app search to return any results. I 
# would like to know more.
#
# TODO
#  - properly check and check what the application environment - DONE!
#  - find a better way to determine the year with log 
#    files that span multiple years
#  - keep track of the lines within a file that have
#    been indexed
#    - note line number
#    - take md5sum of first line


require 'lib/colours'
require 'lib/storage'
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

# set the database and index environment
if ["development", "production", "testing"].member? ENV["RAILS_ENV"]
    environment = ENV["RAILS_ENV"]
else
    environment = "development"
end

# point the index to the right place
RAILS_ROOT = ENV["RAILS_ROOT"] || File.dirname(__FILE__) + '/../rails'

# setup database storage 
storage = Epilog::DBStorage.new
storage.environment = environment
storage.database_config = YAML::load(File.open('database.yml'))
storage.connect_to_database
storage.setup_index("#{RAILS_ROOT}/index/#{environment}/entry/")

# setup watcher
watcher = Epilog::Watcher.new(storage)

# FIXME maybe daemonize correctly?
begin
  # watch indefinitely
  watcher.watch(filename, interval)
rescue Interrupt
  puts "Exiting.".magenta
end

