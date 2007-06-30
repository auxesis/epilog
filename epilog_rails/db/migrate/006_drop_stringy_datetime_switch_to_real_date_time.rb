class DropStringyDatetimeSwitchToRealDateTime < ActiveRecord::Migration
  def self.up
    remove_column :entries, :datetime
    rename_column :entries, :realdatetime, :datetime
  end

  def self.down
    rename_column :entries, :datetime, :realdatetime
    add_column :entries, :datetime, :string
  end
end
