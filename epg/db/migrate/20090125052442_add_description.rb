class AddDescription < ActiveRecord::Migration
  def self.up
    add_column :programs, :description, :text
  end

  def self.down
    drop_column :programs, :description
  end
end
