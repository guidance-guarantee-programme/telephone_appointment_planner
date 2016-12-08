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

ActiveRecord::Schema.define(version: 20161208205325) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "activities", force: :cascade do |t|
    t.integer  "appointment_id", null: false
    t.integer  "user_id"
    t.string   "message",        null: false
    t.string   "type",           null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "prior_owner_id"
    t.integer  "owner_id"
    t.index ["appointment_id"], name: "index_activities_on_appointment_id", using: :btree
    t.index ["type"], name: "index_activities_on_type", using: :btree
  end

  create_table "appointments", force: :cascade do |t|
    t.integer  "guider_id",                                  null: false
    t.datetime "start_at",                                   null: false
    t.datetime "end_at",                                     null: false
    t.string   "first_name",                                 null: false
    t.string   "last_name",                                  null: false
    t.string   "email"
    t.string   "phone",                                      null: false
    t.string   "mobile"
    t.string   "memorable_word",                             null: false
    t.text     "notes"
    t.boolean  "opt_out_of_market_research", default: false, null: false
    t.date     "date_of_birth"
    t.integer  "status",                     default: 0,     null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "agent_id",                                   null: false
    t.integer  "rebooked_from_id"
    t.index ["start_at"], name: "index_appointments_on_start_at", using: :btree
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index", using: :btree
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "bookable_slots", force: :cascade do |t|
    t.integer  "guider_id", null: false
    t.datetime "start_at",  null: false
    t.datetime "end_at",    null: false
    t.index ["guider_id"], name: "index_bookable_slots_on_guider_id", using: :btree
  end

  create_table "group_assignments", id: false, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "user_id",  null: false
    t.index ["group_id"], name: "index_group_assignments_on_group_id", using: :btree
    t.index ["user_id"], name: "index_group_assignments_on_user_id", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "holidays", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "bank_holiday",                 null: false
    t.boolean  "all_day",      default: false, null: false
    t.index ["user_id"], name: "index_holidays_on_user_id", using: :btree
  end

  create_table "schedules", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.datetime "start_at",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "slots", force: :cascade do |t|
    t.integer  "schedule_id",  null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "day_of_week"
    t.integer  "start_hour"
    t.integer  "start_minute"
    t.integer  "end_hour"
    t.integer  "end_minute"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "uid"
    t.string   "organisation_slug"
    t.string   "organisation_content_id"
    t.boolean  "remotely_signed_out",     default: false
    t.boolean  "disabled",                default: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.jsonb    "permissions",             default: "[]",  null: false
    t.integer  "position",                default: 0,     null: false
    t.boolean  "active",                  default: true,  null: false
    t.index ["permissions"], name: "index_users_on_permissions", using: :gin
  end

end
