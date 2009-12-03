class Initialschema < ActiveRecord::Migration
  def self.up
    
    create_table "stations" do |t|
      t.column "xtvd_id", :string, :null => false
      t.column "call_sign", :string
      t.column "name", :string
      t.column "affiliate", :string
      t.column "fcc_cannel_number", :integer
    end
    
    create_table "lineups" do |t|
      t.column "xtvd_id", :string, :null => false
      t.column "name", :string
      t.column "location", :string
      t.column "type", :string
      t.column "device", :string
      t.column "postal_code", :string
    end
    
    create_table "channels" do |t|
      t.column "lineup_id", :integer
      t.column "station_id", :integer
      t.column "channel", :integer
    end
    
    create_table "schedules" do |t|
      t.column "program_id", :integer
      t.column "station_id", :integer
      t.column "start_time", :datetime
      t.column "duration", :integer     # minutes
      t.column "tv_rating", :string
      t.column "close_captioned", :boolean
      t.column "first_run", :boolean
      t.column "hdtv", :boolean
      t.column "dolby", :boolean
      t.column "part", :integer
      t.column "total_parts", :integer
    end
    
    create_table "programs" do |t|
      t.column "xtvd_id", :string
      t.column "title", :string
      t.column "subtitle", :text
      t.column "show_type", :string
      t.column "series", :string
      t.column "syndicated_episode_number", :string
      t.column "original_air_date", :datetime
    end
    
    create_table "genres" do |t|
      t.column "class", :string
      t.column "relevance", :integer
      t.column "program_id", :integer
    end

    create_table "production_crews" do |t|
      t.column "role", :string
      t.column "givenname", :string
      t.column "surname", :string
      t.column "program_id", :integer
    end
        
  end

  def self.down
    
    drop_table "stations"
    drop_table "lineups"
    drop_table "channels"
    drop_table "schedules"
    drop_table "programs"
    drop_table "genres"
    drop_table "production_crews"
    
  end
end
