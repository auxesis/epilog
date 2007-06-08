class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.column :parameters, :string
    end
  end

  def self.down
    drop_table :queries
  end
end
