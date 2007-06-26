class Entry < ActiveRecord::Base
  acts_as_ferret :fields => [:message, :datetime]
end
