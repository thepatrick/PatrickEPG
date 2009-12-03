# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090210081400) do

  create_table "channels", :force => true do |t|
    t.integer "lineup_id"
    t.integer "station_id"
    t.integer "channel"
  end

  create_table "genres", :force => true do |t|
    t.string  "class"
    t.integer "relevance"
    t.integer "program_id"
  end

  create_table "lineups", :force => true do |t|
    t.string "xtvd_id",     :null => false
    t.string "name"
    t.string "location"
    t.string "type"
    t.string "device"
    t.string "postal_code"
  end

  create_table "production_crews", :force => true do |t|
    t.string  "role"
    t.string  "givenname"
    t.string  "surname"
    t.integer "program_id"
  end

  create_table "programs", :force => true do |t|
    t.string   "xtvd_id"
    t.string   "title"
    t.text     "subtitle"
    t.string   "show_type"
    t.string   "series"
    t.string   "syndicated_episode_number"
    t.datetime "original_air_date"
    t.text     "description"
  end

  create_table "recordings", :force => true do |t|
    t.integer  "program_id"
    t.integer  "schedule_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", :force => true do |t|
    t.integer  "program_id"
    t.integer  "station_id"
    t.datetime "start_time"
    t.integer  "duration"
    t.string   "tv_rating"
    t.boolean  "close_captioned"
    t.boolean  "first_run"
    t.boolean  "hdtv"
    t.boolean  "dolby"
    t.integer  "part"
    t.integer  "total_parts"
  end

  create_table "stations", :force => true do |t|
    t.string  "xtvd_id",           :null => false
    t.string  "call_sign"
    t.string  "name"
    t.string  "affiliate"
    t.integer "fcc_cannel_number"
  end

end
