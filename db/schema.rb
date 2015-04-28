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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150428081658) do

  create_table "ads_users", force: true do |t|
    t.string   "name"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "encrypted_password",                              default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          precision: 38, scale: 0, default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "login",                                           default: "", null: false
    t.string   "username"
    t.string   "email"
    t.string   "domain"
  end

  add_index "ads_users", ["reset_password_token"], name: "i_ads_use_res_pas_tok", unique: true
  add_index "ads_users", ["username"], name: "index_ads_users_on_username"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   precision: 38, scale: 0, default: 0
    t.integer  "attempts",   precision: 38, scale: 0, default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "feature_headers", force: true do |t|
    t.integer  "licserver_id", precision: 38, scale: 0
    t.integer  "feature_id",   precision: 38, scale: 0
    t.string   "name"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.datetime "last_seen"
  end

  add_index "feature_headers", ["feature_id"], name: "i_feature_headers_feature_id"
  add_index "feature_headers", ["licserver_id"], name: "i_feature_headers_licserver_id"

  create_table "features", force: true do |t|
    t.string   "name"
    t.integer  "current",           precision: 38, scale: 0
    t.integer  "max",               precision: 38, scale: 0
    t.integer  "licserver_id",      precision: 38, scale: 0
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "feature_header_id", precision: 38, scale: 0
  end

  add_index "features", ["feature_header_id"], name: "i_features_feature_header_id"
  add_index "features", ["licserver_id"], name: "index_features_on_licserver_id"

  create_table "idle_users", force: true do |t|
    t.string   "user"
    t.string   "hostname"
    t.string   "idle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licservers", force: true do |t|
    t.integer  "port",         precision: 38, scale: 0
    t.string   "server"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "monitor_idle", precision: 1,  scale: 0
    t.boolean  "to_delete",    precision: 1,  scale: 0
  end

  create_table "machine_feature_data", force: true do |t|
    t.integer  "machine_id", precision: 38, scale: 0
    t.integer  "feature_id", precision: 38, scale: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "machine_feature_data", ["feature_id"], name: "i_mac_fea_dat_fea_id"
  add_index "machine_feature_data", ["machine_id"], name: "i_mac_fea_dat_mac_id"

  create_table "machine_features", id: false, force: true do |t|
    t.integer  "id",         precision: 38, scale: 0, null: false
    t.integer  "machine_id", precision: 38, scale: 0
    t.integer  "feature_id", precision: 38, scale: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "machine_features", ["feature_id"], name: "i_machine_features_feature_id"
  add_index "machine_features", ["machine_id"], name: "i_machine_features_machine_id"

  create_table "machines", force: true do |t|
    t.string   "name"
    t.integer  "user_id",    precision: 38, scale: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "machines", ["user_id"], name: "index_machines_on_user_id"

  create_table "report_schedules", force: true do |t|
    t.text     "schedule"
    t.text     "monitored_obj"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "title"
    t.string   "time_scope"
    t.boolean  "scheduled",     precision: 1, scale: 0
  end

  create_table "reports", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "report_schedule_id", precision: 38, scale: 0
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "status",             precision: 38, scale: 0, default: 0
  end

  add_index "reports", ["report_schedule_id"], name: "i_reports_report_schedule_id"

  create_table "sys_export_schema_01", id: false, force: true do |t|
    t.decimal  "process_order"
    t.decimal  "duplicate"
    t.decimal  "dump_fileid"
    t.decimal  "dump_position"
    t.decimal  "dump_length"
    t.decimal  "dump_orig_length"
    t.decimal  "dump_allocation"
    t.decimal  "completed_rows"
    t.decimal  "error_count"
    t.decimal  "elapsed_time"
    t.string   "object_type_path",       limit: 200
    t.decimal  "object_path_seqno"
    t.string   "object_type",            limit: 30
    t.string   "in_progress",            limit: 1
    t.string   "object_name",            limit: 500
    t.string   "object_long_name",       limit: 4000
    t.string   "object_schema",          limit: 30
    t.string   "original_object_schema", limit: 30
    t.string   "original_object_name",   limit: 4000
    t.string   "partition_name",         limit: 30
    t.string   "subpartition_name",      limit: 30
    t.decimal  "dataobj_num"
    t.decimal  "flags"
    t.decimal  "property"
    t.decimal  "trigflag"
    t.decimal  "creation_level"
    t.datetime "completion_time"
    t.string   "object_tablespace",      limit: 30
    t.decimal  "size_estimate"
    t.decimal  "object_row"
    t.string   "processing_state",       limit: 1
    t.string   "processing_status",      limit: 1
    t.decimal  "base_process_order"
    t.string   "base_object_type",       limit: 30
    t.string   "base_object_name",       limit: 30
    t.string   "base_object_schema",     limit: 30
    t.decimal  "ancestor_process_order"
    t.decimal  "domain_process_order"
    t.decimal  "parallelization"
    t.decimal  "unload_method"
    t.decimal  "load_method"
    t.decimal  "granules"
    t.decimal  "scn"
    t.string   "grantor",                limit: 30
    t.text     "xml_clob"
    t.decimal  "parent_process_order"
    t.string   "name",                   limit: 30
    t.string   "value_t",                limit: 4000
    t.decimal  "value_n"
    t.decimal  "is_default"
    t.decimal  "file_type"
    t.string   "user_directory",         limit: 4000
    t.string   "user_file_name",         limit: 4000
    t.string   "file_name",              limit: 4000
    t.decimal  "extend_size"
    t.decimal  "file_max_size"
    t.string   "process_name",           limit: 30
    t.datetime "last_update"
    t.string   "work_item",              limit: 30
    t.decimal  "object_number"
    t.decimal  "completed_bytes"
    t.decimal  "total_bytes"
    t.decimal  "metadata_io"
    t.decimal  "data_io"
    t.decimal  "cumulative_time"
    t.decimal  "packet_number"
    t.decimal  "instance_id"
    t.string   "old_value",              limit: 4000
    t.decimal  "seed"
    t.decimal  "last_file"
    t.string   "user_name",              limit: 30
    t.string   "operation",              limit: 30
    t.string   "job_mode",               limit: 30
    t.decimal  "queue_tabnum"
    t.string   "control_queue",          limit: 30
    t.string   "status_queue",           limit: 30
    t.string   "remote_link",            limit: 4000
    t.decimal  "version"
    t.string   "job_version",            limit: 30
    t.string   "db_version",             limit: 30
    t.string   "timezone",               limit: 64
    t.string   "state",                  limit: 30
    t.decimal  "phase"
    t.raw      "guid",                   limit: 16
    t.datetime "start_time"
    t.decimal  "block_size"
    t.decimal  "metadata_buffer_size"
    t.decimal  "data_buffer_size"
    t.decimal  "degree"
    t.string   "platform",               limit: 101
    t.decimal  "abort_step"
    t.string   "instance",               limit: 60
    t.decimal  "cluster_ok"
    t.string   "service_name",           limit: 100
    t.string   "object_int_oid",         limit: 32
  end

  add_index "sys_export_schema_01", ["base_process_order"], name: "sys_mtable_00001dec1_ind_2"
  add_index "sys_export_schema_01", ["object_schema", "object_name", "object_type"], name: "sys_mtable_00001dec1_ind_1"
  add_index "sys_export_schema_01", ["process_order", "duplicate"], name: "sys_c0021059", unique: true

  create_table "sys_import_schema_01", id: false, force: true do |t|
    t.decimal  "process_order"
    t.decimal  "duplicate"
    t.decimal  "dump_fileid"
    t.decimal  "dump_position"
    t.decimal  "dump_length"
    t.decimal  "dump_orig_length"
    t.decimal  "dump_allocation"
    t.decimal  "completed_rows"
    t.decimal  "error_count"
    t.decimal  "elapsed_time"
    t.string   "object_type_path",       limit: 200
    t.decimal  "object_path_seqno"
    t.string   "object_type",            limit: 30
    t.string   "in_progress",            limit: 1
    t.string   "object_name",            limit: 500
    t.string   "object_long_name",       limit: 4000
    t.string   "object_schema",          limit: 30
    t.string   "original_object_schema", limit: 30
    t.string   "original_object_name",   limit: 4000
    t.string   "partition_name",         limit: 30
    t.string   "subpartition_name",      limit: 30
    t.decimal  "dataobj_num"
    t.decimal  "flags"
    t.decimal  "property"
    t.decimal  "trigflag"
    t.decimal  "creation_level"
    t.datetime "completion_time"
    t.string   "object_tablespace",      limit: 30
    t.decimal  "size_estimate"
    t.decimal  "object_row"
    t.string   "processing_state",       limit: 1
    t.string   "processing_status",      limit: 1
    t.decimal  "base_process_order"
    t.string   "base_object_type",       limit: 30
    t.string   "base_object_name",       limit: 30
    t.string   "base_object_schema",     limit: 30
    t.decimal  "ancestor_process_order"
    t.decimal  "domain_process_order"
    t.decimal  "parallelization"
    t.decimal  "unload_method"
    t.decimal  "load_method"
    t.decimal  "granules"
    t.decimal  "scn"
    t.string   "grantor",                limit: 30
    t.text     "xml_clob"
    t.decimal  "parent_process_order"
    t.string   "name",                   limit: 30
    t.string   "value_t",                limit: 4000
    t.decimal  "value_n"
    t.decimal  "is_default"
    t.decimal  "file_type"
    t.string   "user_directory",         limit: 4000
    t.string   "user_file_name",         limit: 4000
    t.string   "file_name",              limit: 4000
    t.decimal  "extend_size"
    t.decimal  "file_max_size"
    t.string   "process_name",           limit: 30
    t.datetime "last_update"
    t.string   "work_item",              limit: 30
    t.decimal  "object_number"
    t.decimal  "completed_bytes"
    t.decimal  "total_bytes"
    t.decimal  "metadata_io"
    t.decimal  "data_io"
    t.decimal  "cumulative_time"
    t.decimal  "packet_number"
    t.decimal  "instance_id"
    t.string   "old_value",              limit: 4000
    t.decimal  "seed"
    t.decimal  "last_file"
    t.string   "user_name",              limit: 30
    t.string   "operation",              limit: 30
    t.string   "job_mode",               limit: 30
    t.decimal  "queue_tabnum"
    t.string   "control_queue",          limit: 30
    t.string   "status_queue",           limit: 30
    t.string   "remote_link",            limit: 4000
    t.decimal  "version"
    t.string   "job_version",            limit: 30
    t.string   "db_version",             limit: 30
    t.string   "timezone",               limit: 64
    t.string   "state",                  limit: 30
    t.decimal  "phase"
    t.raw      "guid",                   limit: 16
    t.datetime "start_time"
    t.decimal  "block_size"
    t.decimal  "metadata_buffer_size"
    t.decimal  "data_buffer_size"
    t.decimal  "degree"
    t.string   "platform",               limit: 101
    t.decimal  "abort_step"
    t.string   "instance",               limit: 60
    t.decimal  "cluster_ok"
    t.string   "service_name",           limit: 100
    t.string   "object_int_oid",         limit: 32
  end

  add_index "sys_import_schema_01", ["base_process_order"], name: "sys_mtable_00001df75_ind_2"
  add_index "sys_import_schema_01", ["object_schema", "object_name", "object_type"], name: "sys_mtable_00001df75_ind_1"
  add_index "sys_import_schema_01", ["process_order", "duplicate"], name: "sys_c0021060", unique: true

  create_table "tags", force: true do |t|
    t.string   "title"
    t.integer  "licserver_id", precision: 38, scale: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "tags", ["licserver_id"], name: "index_tags_on_licserver_id"

  create_table "unique_user_kill_lists", force: true do |t|
    t.integer  "licserver_id", precision: 38, scale: 0
    t.string   "feature_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unique_user_kill_lists", ["licserver_id"], name: "i_uni_use_kil_lis_lic_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "last_seen_at"
  end

  create_table "watch_lists", force: true do |t|
    t.integer  "ads_user_id", precision: 38, scale: 0
    t.string   "model_type"
    t.integer  "model_id",    precision: 38, scale: 0
    t.text     "note"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "active",      precision: 1,  scale: 0
  end

  add_index "watch_lists", ["ads_user_id"], name: "i_watch_lists_ads_user_id"

end
