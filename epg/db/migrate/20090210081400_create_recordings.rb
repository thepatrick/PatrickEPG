class CreateRecordings < ActiveRecord::Migration
  def self.up
    create_table :recordings do |t|
      t.column :program_id, :integer
      t.column :schedule_id, :integer
      t.column :state, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :recordings
  end
end
