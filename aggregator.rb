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
#  - check what the environment is and set it globally
#  - find a better way to determine the year with log 
#    files that span multiple years
#  - keep track of the lines within a file that have
#    been indexed
#    - note line number
#    - take md5sum of first line



require 'active_record'
require 'yaml'
require 'md5'
require 'term/ansicolor'
require 'fileutils'
require 'ftools'
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

  def initialize
    # temporary hack for setting the database and index environment
    @environment = 'development'
  end

  def get_database_config(config='database.yml')
    @db_config = YAML::load(File.open(config))
  end

  def connect_to_database
    ActiveRecord::Base.configurations = @db_config
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
        retry # risky but doable
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

  def store_and_index(message, datetime, digest, filename, filestat)
    # we pass in the mtime of the file in as the year.
    # there needs to be a better check for working out
    # what the year *actually* is though.
    year = filestat.mtime.year
    time = rfc3164_to_ruby_datetime(datetime, year)  

    entry = store(message, time, digest, filename)

    index(entry)

  end 
end




def set_state(stat, contents)
  @file_stat = stat
  @file_contents = contents
end

def watch(filename, interval)

  contents = File.open(filename).readlines
  stat = File.stat(filename)

  set_state(stat, contents)

  while true do 
    @current_file_stat = File.stat(filename)

    if @file_stat != @current_file_stat then
      puts "#{filename.split.pop} has changed.".green

      @current_file_contents = File.open(filename).readlines
      
      # dodgy hack, isn't accurate
      lines = @current_file_contents - @file_contents 

      lines.each do |line|
        datetime = line[0..15]
        message = line[16..-1]
        digest = MD5.hexdigest(line)

        @s.store_and_index(message, 
                           datetime, 
                           digest, 
                           filename, # god this is nasty
                           @current_file_stat
                          )
      end
   
      set_state(@current_file_stat, @current_file_contents)

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

# how horrible
if ARGV[1] then interval = ARGV[1].to_i else interval = 2 end

# temporary hack for setting the database and index environment
@environment = 'development'

@s = Storage.new
@s.get_database_config
@s.connect_to_database
@s.setup_index("epilog_rails/index/#{@environment}/entry/")

watch(filename, interval)

