# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140402064524) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :precision => 38, :scale => 0, :default => 0
    t.integer  "attempts",   :precision => 38, :scale => 0, :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "feature_headers", :force => true do |t|
    t.integer  "licserver_id", :precision => 38, :scale => 0
    t.integer  "feature_id",   :precision => 38, :scale => 0
    t.string   "name"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.datetime "last_seen"
  end

  add_index "feature_headers", ["feature_id"], :name => "i_feature_headers_feature_id"
  add_index "feature_headers", ["licserver_id"], :name => "i_feature_headers_licserver_id"

  create_table "features", :force => true do |t|
    t.string   "name"
    t.integer  "current",           :precision => 38, :scale => 0
    t.integer  "max",               :precision => 38, :scale => 0
    t.integer  "licserver_id",      :precision => 38, :scale => 0
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "feature_header_id", :precision => 38, :scale => 0
  end

  add_index "features", ["feature_header_id"], :name => "i_features_feature_header_id"
  add_index "features", ["licserver_id"], :name => "index_features_on_licserver_id"

  create_table "idle_users", :force => true do |t|
    t.string   "user"
    t.string   "hostname"
    t.string   "idle"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "licservers", :force => true do |t|
    t.integer  "port",         :precision => 38, :scale => 0
    t.string   "server"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.boolean  "monitor_idle", :precision => 1,  :scale => 0
    t.boolean  "to_delete",    :precision => 1,  :scale => 0
  end

  create_table "machine_feature_data", :force => true do |t|
    t.integer  "machine_id", :precision => 38, :scale => 0
    t.integer  "feature_id", :precision => 38, :scale => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "machine_feature_data", ["feature_id"], :name => "i_mac_fea_dat_fea_id"
  add_index "machine_feature_data", ["machine_id"], :name => "i_mac_fea_dat_mac_id"

  create_table "machine_features", :force => true do |t|
    t.integer  "machine_id", :precision => 38, :scale => 0
    t.integer  "feature_id", :precision => 38, :scale => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "machine_features", ["feature_id"], :name => "i_machine_features_feature_id"
  add_index "machine_features", ["machine_id"], :name => "i_machine_features_machine_id"

  create_table "machines", :force => true do |t|
    t.string   "name"
    t.integer  "user_id",    :precision => 38, :scale => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "machines", ["user_id"], :name => "index_machines_on_user_id"

  create_table "report_schedules", :force => true do |t|
    t.text     "schedule"
    t.text     "monitored_obj"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "title"
    t.string   "time_scope"
    t.boolean  "scheduled",     :precision => 1, :scale => 0
  end

  create_table "reports", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "report_schedule_id", :precision => 38, :scale => 0
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "status",             :precision => 38, :scale => 0, :default => 0
  end

  add_index "reports", ["report_schedule_id"], :name => "i_reports_report_schedule_id"

  create_table "tags", :force => true do |t|
    t.string   "title"
    t.integer  "licserver_id", :precision => 38, :scale => 0
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "tags", ["licserver_id"], :name => "index_tags_on_licserver_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
