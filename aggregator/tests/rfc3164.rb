require 'test/unit'

require File.join(File.dirname(__FILE__), '..', 'lib', 'rfc3164')

class RFC3164Test < Test::Unit::TestCase

  # tosf = ThreeOneSixFour = 3164

  def test_timestamp_to_datetime

    tosf_timestamp = "Jun 4 06:27:17"

    ruby_timestamp = Epilog::RFC3164.to_ruby_datetime(tosf_timestamp)

    assert_equal ruby_timestamp, Time.mktime(Time.now.year, 6, 4, 6, 27, 17)

  end

  def test_timestamp_to_datetime_with_specified_year
    
    tosf_timestamp = "Oct 16 22:04:19"

    ruby_timestamp = Epilog::RFC3164.to_ruby_datetime(tosf_timestamp, 2005)

    assert_equal ruby_timestamp, Time.mktime(2005, 10, 16, 22, 4, 19)

  end

  def test_bogus_timestamp_to_datetime
    tosf_timestamp = "Feb 32 11:44:33" 
    assert_raise ArgumentError do
      Epilog::RFC3164.to_ruby_datetime(tosf_timestamp, 2005)
    end

  end

  def test_extra_day_in_month_gets_rounded_up_to_next_month
    tosf_timestamp = "Nov 31 08:30:25"
    ruby_timestamp = Epilog::RFC3164.to_ruby_datetime(tosf_timestamp)

    assert_equal ruby_timestamp, Time.mktime(Time.now.year, 12, 1, 8, 30, 25)

  end


end
