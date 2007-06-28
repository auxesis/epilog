class Entry < ActiveRecord::Base
  acts_as_ferret :fields => [:message, :datetime, :id]

  # usefully ripped from http://www.railsenvy.com/2007/2/19/acts-as-ferret-tutorial
  def self.full_text_search(q, options = {})
    return nil if q.nil? or q==""
    default_options = {:limit => 10, :page => 1}
    options = default_options.merge options
                
    # get the offset based on what page we're on
    options[:offset] = options[:limit] * (options.delete(:page).to_i-1)  

    # now do the query with our options
    results = Entry.find_by_contents(q, options)
    return [results.total_hits, results]
  end
end
