#!/usr/bin/env ruby

require 'active_record'
require 'yaml'
require 'fileutils'
require 'ferret'

#require File.join(File.dirname(__FILE__), '..', 'lib', 'rfc3164')
#require File.join(File.dirname(__FILE__), '..', 'lib', 'db')
require 'lib/rfc3164'

include Ferret

class Entry < ActiveRecord::Base ; end

module Epilog

  class DBStorage
    # Class for dealing with datastores. Handles databases
    # through ActiveRecord, and indexes through Ferret

    def initialize(environment)
      # temporary hack for setting the database and index environment
      @environment = environment
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
        puts entry.message
        puts entry.datetime
    end

    def commit(message, datetime, digest, filename, filestat)
      # we pass in the mtime of the file in as the year.
      # there needs to be a better check for working out
      # what the year *actually* is.
      year = filestat.mtime.year
      time = Epilog::RFC3164.to_ruby_datetime(datetime, year)  

      entry = store(message, time, digest, filename)

      index(entry) unless entry.blank?

    end 

  end

end 
