#!/usr/bin/env ruby

require 'active_record'
require 'yaml'
require 'fileutils'
require 'ferret'

#require File.join(File.dirname(__FILE__), '..', 'lib', 'rfc3164')
require 'lib/rfc3164'

include Ferret

class Entry < ActiveRecord::Base ; end

module Epilog

  # Handles databases through ActiveRecord, and indexing through Ferret

  class DBStorage

    attr_accessor :environment, :database_config

    def connect_to_database
      ActiveRecord::Base.configurations = @database_config
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[@environment])
    end

    def setup_index(path='index')
      FileUtils.mkdir_p(path) if not File.exists? path
      raise "Directory #{path} isn't writable!" if not File.writable? path

      @index = Index::Index.new(:path => path)
    end

    def store(data)
      digest = data[:digest] 
      if Entry.find(:first, :conditions => [ "digest = ?", digest]) then
        puts "Entry #{digest} already exists!".yellow
      else
        begin
          entry = Entry.new(data)
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
                    :digest => entry.digest } 
        puts entry.message
    end

    def commit(data)
      # we pass in the mtime of the file in as the year.
      # there needs to be a better check for working out
      # what the year *actually* is.

      year = data[:stat].mtime.year
      data.delete(:stat)

      ruby_datetime = Epilog::RFC3164.to_ruby_datetime(data[:datetime], year)  
      data[:datetime] = ruby_datetime

      entry = store(data)

      index(entry) unless entry.blank?

    end 

  end

end 
