module Relevance
  # Streamlined
  # (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
  # Streamlined is freely distributable under the terms of an MIT-style license.
  # For details, see http://streamlined.relevancellc.com
  #
  # Adds several utility methods to ActiveRecord::Base for supporting view columns/
  module ActiveRecordExtensions

    def user_columns
      self.content_columns.find_all do |d|
        !d.name.match /(_at|_on|position|lock_version|_id|password_hash)$/
      end
    end
    def find_by_like(value, *columns)
      self.find(:all, :conditions=>conditions_by_like(value, *columns))
    end
    def find_by_criteria(template)
      self.find(:all, :conditions=>conditions_by_criteria(template))      
    end
    def conditions_by_like(value, *columns)
      columns = self.user_columns if columns.size==0
      columns = columns[0] if columns[0].kind_of?(Array)
      conditions = columns.map {|c|
        c = c.name if c.kind_of? ActiveRecord::ConnectionAdapters::Column
        "#{c} LIKE " + ActiveRecord::Base.connection.quote("%#{value}%")
      }.join(" OR ")
    end
    def conditions_by_criteria(template)
      attrs = template.class.columns.map &:name
      vals = []
      attrs.each {|a| vals << "#{a} LIKE " + ActiveRecord::Base.connection.quote("%#{template.send(a)}%") if !template.send(a).blank? && a != 'id' && a != 'lock_version' }
      vals.join(" AND ")
    end
    def has_manies()
      self.reflect_on_all_associations.select {|x| x.macro == :has_many || x.macro == :has_and_belongs_to_many}
    end
    def has_ones()
      self.reflect_on_all_associations.select {|x| x.macro == :has_one || x.macro == :belongs_to}
    end
  end
end

ActiveRecord::Base.extend Relevance::ActiveRecordExtensions