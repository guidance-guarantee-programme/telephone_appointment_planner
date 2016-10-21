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

ActiveRecord::Schema.define(version: 20161021120409) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointment_attempts", force: :cascade do |t|
    t.string   "first_name",               null: false
    t.string   "last_name",                null: false
    t.date     "date_of_birth",            null: false
    t.boolean  "defined_contribution_pot", null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "appointments", force: :cascade do |t|
    t.integer  "guider_id",                                             null: false
    t.datetime "start_at",                                              null: false
    t.datetime "end_at",                                                null: false
    t.string   "first_name",                                            null: false
    t.string   "last_name",                                             null: false
    t.string   "email"
    t.string   "phone",                                                 null: false
    t.string   "mobile"
    t.string   "memorable_word",                                        null: false
    t.text     "notes"
    t.boolean  "opt_out_of_market_research",            default: false, null: false
    t.string   "where_did_you_hear_about_pension_wise", default: "",    null: false
    t.string   "who_is_your_pension_provider",          default: "",    null: false
    t.date     "date_of_birth"
    t.integer  "status",                                default: 0,     null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

end
