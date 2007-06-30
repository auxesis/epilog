class AddProperDateTime < ActiveRecord::Migration
  def self.up
    add_column :entries, :realdatetime, :datetime
  end

  def self.down
    remove_column :entries, :realdatetime
  end
end
