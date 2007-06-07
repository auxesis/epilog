class CreateBasicStructure < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.column :message, :string
      t.column :datetime, :string
    end
  end

  def self.down
    drop_table :entries
  end
end
