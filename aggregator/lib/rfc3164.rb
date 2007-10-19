#!/usr/bin/env ruby

require 'date'
require 'time'


module Epilog

  # example of how to turn a rfc3164 formatted timestamp into
  # a real ruby datetime object.

  #rfc3164_timestamp = "Jun 4 06:27:17"
  #time = RFC3164.rfc3164_to_ruby_datetime(rfc3164_timestamp)
  #puts time

  class RFC3164

    # helper function to convert an abbreviated month name
    # to a month number
    def RFC3164.human_month_to_number(month)
      month = month.capitalize unless month == nil
      if Date::ABBR_MONTHNAMES.include?(month) then
        return Date::ABBR_MONTHNAMES.rindex(month)
      else
        raise 'Not a valid month!'
      end
    end


    # scary assumption!
    # we guess that the year is the current year unless we're passed it
    # explicitly. bloody useless rfc3164 doesn't require a year to be 
    # specified
    #
    def RFC3164.to_ruby_datetime(rfc3164_timestamp, year=Time.now.year) 
  
      rfc3164_timestamp_split = rfc3164_timestamp.split
  
      abbreviated_month = rfc3164_timestamp_split[0]

      # convert the abbreviated month to a month number
      begin
        month = RFC3164.human_month_to_number(abbreviated_month)
      rescue RuntimeError
        raise "Please provide a valid rfc3164 timestamp!"
      end

      # assign all the bits to names
      day = rfc3164_timestamp_split[1]
      timestamp = rfc3164_timestamp_split[2]
      hour = timestamp.split(':')[0]
      min = timestamp.split(':')[1]
      sec = timestamp.split(':')[2]

      # construct the time object
      time = Time.mktime(year, month, day, hour, min, sec)

      return time
    end

  end # class

end #module

