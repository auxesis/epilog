class AddFilenameField < ActiveRecord::Migration
  def self.up
    add_column :entries, :filename, :string
  end

  def self.down
    remove_column :entries, :filename
  end
end


