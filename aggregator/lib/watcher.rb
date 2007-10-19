
require 'active_record'
require 'yaml'
require 'md5'
require 'term/ansicolor'
require 'fileutils'
require 'ftools'
require 'libunixdatetime.rb'
require 'ferret'

module Epilog

  class Watcher  

    def initialize(storage)
      @storage = storage
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

            @storage.store_and_index(message, datetime, digest, filename, @current_file_stat )
          end
   
          set_state(@current_file_stat, @current_file_contents)

        else 
           puts "#{filename.split.pop} hasn't changed.".blue
        end

        sleep interval
      end

    end #def

  end #class

end #module


