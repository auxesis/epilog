#!/usr/bin/env ruby
#
# aggregator.rb
# reads log files and pops them into a database
#
# Doesn't do any fancy transformations of the data. The raw lines
# (and all extra spaces) are inserted verbatim. An md5sum of the 
# intact line is used as a unique identifier of the line so 
# duplicates are handled "nicer". 
#

require 'active_record'
require 'yaml'
require 'md5'
require 'term/ansicolor'

class Entry < ActiveRecord::Base; end

class Color
  class << self
    include Term::ANSIColor
  end
end

class String
  include Term::ANSIColor
end

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

def log_to_database(message, datetime, digest, filename)
  if Entry.find(:first, :conditions => [ "digest = ?", digest]) then
    puts "Entry #{digest} already exists!".yellow
  else
    begin
      log = Entry.new("message" => message, "datetime" => datetime, "digest" => digest, "filename" => filename)
      log.save
    rescue SQLite3::BusyException
      sleep 2
      puts 'Database contention! Retrying.'.red
      retry
    end
  end
end

def watch(filename, interval)

  @file_contents = File.open(filename).readlines
  @file_state = File.stat(filename)

  basename = filename.split.pop

  while true do 
    @current_file_state = File.stat(filename)

    if @current_file_state != @file_state then
      puts "#{filename.split.pop} has changed.".green
      @current_file_contents = File.open(filename).readlines

      lines = @current_file_contents - @file_contents

      lines.each do |line|
        datetime = line[0..15]
        message = line[16..-1]
        digest = MD5.hexdigest(line)

        log_to_database(message, datetime, digest, basename)

      end
    
     @file_state = @current_file_state
     @file_contents = @current_file_contents

   else 
     puts "#{filename.split.pop} hasn't changed.".blue
   end

  sleep interval
  end
end

# let's begin

if ARGV.length < 1 then
  puts "Usage: aggregator.rb <file> [interval]"
  exit 1
end

filename = ARGV[0]

if ARGV[1] then
  interval = ARGV[1].to_i
else 
  interval = 2
end

config = get_config
connect_to_database(config)

watch(filename, interval)



