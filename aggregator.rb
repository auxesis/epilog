#!/usr/bin/env ruby
#
# aggregator.rb
# reads log files and pops them into a database
#

require 'active_record'
require 'yaml'

class Entry < ActiveRecord::Base; end

def get_config
  db_config = YAML::load(File.open('database.yml'))
end

def connect_to_database(config)
  begin 
    ActiveRecord::Base.configurations = config
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['development'])
  rescue
    puts "Problem connecting to database!"
  end
end

def log_to_database(message, datetime)
  begin
    log = Entry.new("message" => message, "datetime" => datetime)
    log.save
  rescue SQLite3::BusyException
    sleep 2
    puts 'db contention!'
    retry
  end

end

# let's begin

if ARGV.length < 1 then
  puts "Usage: aggregator.rb <logfile>"
  exit
end


config = get_config
connect_to_database(config)

logfile = ARGV[0]

@time = 1

@file_contents = File.open(logfile).readlines
@file_state = File.stat(logfile)

while true do 
  @current_file_state = File.stat(logfile)

  if @current_file_state != @file_state then
    puts "file has changed"
    @current_file_contents = File.open(logfile).readlines

    lines = @file_contents & @current_file_contents

    lines.each do |line|
      datetime = line[0..15]
      message = line[16..-1]

      log_to_database(message, datetime)

    end
    
    @file_state = @current_file_state
    @file_contents = @current_file_contents

  else 
    puts "file hasn't changed"
  end


  sleep @time
end


