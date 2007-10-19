#!/usr/bin/env ruby

require 'term/ansicolor'

# gimme colour baby!
class Color
  class << self
    include Term::ANSIColor
  end
end

class String
  include Term::ANSIColor
end

