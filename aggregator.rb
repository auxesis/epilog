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
# would like to know more!
#

require 'active_record'
require 'yaml'
require 'md5'
require 'term/ansicolor'
require 'fileutils'
require 'libunixdatetime.rb'
require 'ferret'
include Ferret

class Entry < ActiveRecord::Base; end

# gimme colour baby!
class Color
  class << self
    include Term::ANSIColor
  end
end

class String
  include Term::ANSIColor
end

class Storage
  # Class for dealing with datastores. Handles databases
  # through ActiveRecord, and indexes through Ferret

  def get_database_config(config='database.yml')
    db_config = YAML::load(File.open(config))
  end

  def connect_to_database
    ActiveRecord::Base.configurations = db_config
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[@environment])
  end


  def setup_index(path='index')

    FileUtils.mkdir_p(path) if not File.exists? path
    raise "Directory #{path} isn't writable!" if not File.writable? path

    @index = Index::Index.new(:path => path)
  end

  def store(message, datetime, digest, filename)
    if Entry.find(:first, :conditions => [ "digest = ?", digest]) then
      puts "Entry #{digest} already exists!".yellow
    else
      begin
        entry = Entry.new("message" => message, 
                          "datetime" => datetime, 
                          "digest" => digest, 
                          "filename" => filename) 
        entry.save
        return entry
      rescue SQLite3::BusyException
        sleep 2
        puts 'Database contention! Retrying.'.red
        retry # risky but doable!
      end
    end
  end

  def index(entry)
      @index << { :message => entry.message, 
                  :datetime => entry.datetime, 
                  :id => entry.id,
                  :digest => entry.digest 
      } # the search in the rails app doesn't work without 
        # passing in the digest. i'd like to know why!
  end

  def store_and_index(message, datetime, digest, file)
    # we pass in the mtime of the file in as the year.
    # there needs to be a better check for working out
    # what the year *actually* is though.
    year = file.mtime.year
    time = rfc3164_to_ruby_datetime(datetime, year)  
    filename  = file.path.split('/').pop

    store(message, time, digest)

    index(entry)

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
      lines = @current_file_contents - @file_contents # dodgy hack, probably doesn't work in the real world

      lines.each do |line|
        datetime = line[0..15]
        message = line[16..-1]
        digest = MD5.hexdigest(line)

        @s.store_and_index(message, datetime, digest, basename, @current_file_state)

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

# how horrible! 
if ARGV[1] then interval = ARGV[1].to_i else interval = 2 end

# temporary hack for setting the database and index environment
@environment = 'development'

@s = Storage.new
@s.get_database_config
@s.connect_to_database
@s.setup_index("epilog_rails/index/#{@environment}/entry/")

watch(filename, interval)

