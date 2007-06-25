class AddMd5Field < ActiveRecord::Migration
  def self.up
    add_column :entries, :digest, :string
  end

  def self.down
    remove_column :entries, :digest
  end
end
