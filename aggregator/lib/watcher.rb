#!/usr/bin/env ruby
#
#
# TODO
#  - keep track of lines better! know where we are in the file
#    (each_with_index will help)
#

require 'yaml'
require 'md5'
require 'fileutils'
require 'ftools'
File.join(File.dirname(__FILE__), '..', 'lib', 'storage')
File.join(File.dirname(__FILE__), '..', 'lib', 'colours')

module Epilog

  class Watcher  

    def initialize(storage)
      @storage = storage
    end

    def set_state(stat, contents)
      @file_stat = stat
      @file_contents = contents
    end

    def commit(lines, filename)
      # break up each of the lines
      lines.each do |line|
        datetime = line[0..15]
        message = line[16..-1]
        digest = MD5.hexdigest(line)

        data = { :datetime => datetime, :message => message, :digest => digest, :filename => filename }

        @storage.commit(data, @current_file_stat)
      end
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
      
          # FIXME this isn't accurate
          lines = @current_file_contents - @file_contents 

          commit(lines, filename)
   
          set_state(@current_file_stat, @current_file_contents)

        else 
           puts "#{filename.split.pop} hasn't changed.".blue
        end

        sleep interval
      end

    end #method

  end #class

end #module


