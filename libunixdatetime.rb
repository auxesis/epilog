#!/usr/bin/env ruby
#
#

require 'date'
require 'time'

def human_month_to_number(month)
  month = month.capitalize
  if Date::ABBR_MONTHNAMES.include?(month) then
    return Date::ABBR_MONTHNAMES.rindex(month)
  else
    raise 'Not a valid month!'
  end
end

def rfc3164_to_ruby_datetime(rfc3164_timestamp)
  split_stamp = rfc3164_timestamp.split
  
  year = Time.now.year # scary assumption! bloody useless rfc3164
  month_human = split_stamp[0]

  begin
    month = human_month_to_number(month_human)
  rescue RuntimeError
    raise "Please provide a valid rfc3164 timestamp!"
  end

  day = split_stamp[1]
  timestamp = split_stamp[2]
  hour = timestamp.split(':')[0]
  min = timestamp.split(':')[1]
  sec = timestamp.split(':')[2]

  time = Time.mktime(year, month, day, hour, min, sec)

  return time
end

timestamp = "Jun 4 06:27:17"

time = rfc3164_to_ruby_datetime(timestamp)

puts time


