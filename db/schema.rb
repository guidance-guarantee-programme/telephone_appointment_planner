# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_04_102028) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.integer "user_id"
    t.string "message", default: "", null: false
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "prior_owner_id"
    t.integer "owner_id"
    t.datetime "resolved_at"
    t.integer "resolver_id"
    t.index ["appointment_id"], name: "index_activities_on_appointment_id"
    t.index ["type"], name: "index_activities_on_type"
  end

  create_table "appointments", id: :serial, force: :cascade do |t|
    t.integer "guider_id", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email"
    t.string "phone", null: false
    t.string "mobile", default: ""
    t.string "memorable_word", null: false
    t.text "notes", default: ""
    t.date "date_of_birth"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "agent_id", null: false
    t.integer "rebooked_from_id"
    t.boolean "dc_pot_confirmed", default: true, null: false
    t.string "type_of_appointment", default: "", null: false
    t.integer "where_you_heard", default: 0, null: false
    t.string "address_line_one", default: "", null: false
    t.string "address_line_two", default: "", null: false
    t.string "address_line_three", default: "", null: false
    t.string "town", default: "", null: false
    t.string "county", default: "", null: false
    t.string "postcode", default: "", null: false
    t.datetime "batch_processed_at"
    t.datetime "rescheduled_at"
    t.string "gdpr_consent", default: "", null: false
    t.string "pension_provider", default: "", null: false
    t.boolean "accessibility_requirements", default: false, null: false
    t.datetime "processed_at"
    t.integer "casebook_appointment_id"
    t.boolean "third_party_booking", default: false, null: false
    t.boolean "smarter_signposted", default: false
    t.string "data_subject_name", default: "", null: false
    t.integer "data_subject_age"
    t.boolean "data_subject_consent_obtained", default: false, null: false
    t.boolean "printed_consent_form_required", default: false, null: false
    t.boolean "power_of_attorney", default: false, null: false
    t.string "consent_address_line_one", default: "", null: false
    t.string "consent_address_line_two", default: "", null: false
    t.string "consent_address_line_three", default: "", null: false
    t.string "consent_town", default: "", null: false
    t.string "consent_county", default: "", null: false
    t.string "consent_postcode", default: "", null: false
    t.boolean "bsl_video", default: false, null: false
    t.boolean "email_consent_form_required", default: false, null: false
    t.string "email_consent", default: "", null: false
    t.date "data_subject_date_of_birth"
    t.boolean "lloyds_signposted", default: false, null: false
    t.string "secondary_status", default: "", null: false
    t.string "schedule_type", default: "pension_wise", null: false
    t.string "unique_reference_number", default: "", null: false
    t.string "referrer", default: "", null: false
    t.boolean "small_pots", default: false, null: false
    t.string "rescheduling_reason", default: "", null: false
    t.boolean "nudged", default: false, null: false
    t.string "nudge_confirmation", default: "", null: false
    t.string "nudge_eligibility_reason", default: "", null: false
    t.string "country_code", default: "GB", null: false
    t.boolean "welsh", default: false, null: false
    t.string "cancelled_via", default: "", null: false
    t.string "rescheduling_route", default: "", null: false
    t.string "other_reason", default: "", null: false
    t.string "attended_digital"
    t.string "adjustments", default: "", null: false
    t.boolean "status_reminder_sent"
    t.index "guider_id, tsrange(start_at, end_at)", name: "index_appointments_guider_id_tsrange_start_at_end_at", using: :gist
    t.index "tsrange(start_at, end_at)", name: "index_appointments_tsrange_start_at_end_at", using: :gist
    t.index ["guider_id", "start_at"], name: "index_appointments_guider_start_schedule_status", where: "(((schedule_type)::text = 'pension_wise'::text) AND (status <> ALL ('{6,7,8,9}'::integer[])))"
    t.index ["guider_id", "start_at"], name: "unique_slot_guider_in_appointment", unique: true, where: "((status <> ALL (ARRAY[5, 6, 7, 8, 9])) AND (start_at > '2024-01-01 00:00:00'::timestamp without time zone))"
    t.index ["guider_id"], name: "index_appointments_guider_schedule_status", where: "(((schedule_type)::text = 'pension_wise'::text) AND (status <> ALL ('{6,7,8,9}'::integer[])))"
    t.index ["guider_id"], name: "index_appointments_on_guider_id"
    t.index ["schedule_type"], name: "index_appointments_on_schedule_type"
    t.index ["start_at", "end_at", "guider_id"], name: "index_appointments_on_start_at_and_end_at_and_guider_id"
    t.index ["start_at"], name: "index_appointments_on_start_at"
  end

  create_table "audits", id: :serial, force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "bookable_slots", id: :serial, force: :cascade do |t|
    t.integer "guider_id", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "schedule_type", default: "pension_wise", null: false
    t.index "tsrange(start_at, end_at)", name: "index_bookable_slots_tsrange_start_at_end_at", using: :gist
    t.index ["guider_id"], name: "index_bookable_slots_on_guider_id"
    t.index ["schedule_type"], name: "index_bookable_slots_on_schedule_type"
    t.index ["start_at", "end_at"], name: "index_bookable_slots_on_start_at_and_end_at"
  end

  create_table "email_lookups", force: :cascade do |t|
    t.string "organisation_id", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_assignments", id: false, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "user_id", null: false
    t.index ["group_id"], name: "index_group_assignments_on_group_id"
    t.index ["user_id"], name: "index_group_assignments_on_user_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organisation_content_id", default: "", null: false
  end

  create_table "holidays", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "bank_holiday", null: false
    t.boolean "all_day", default: false, null: false
    t.index "tsrange(start_at, end_at)", name: "index_holidays_tsrange_start_at_end_at", using: :gist
    t.index "user_id, tsrange(start_at, end_at)", name: "index_holidays_userid_tsrange", using: :gist
    t.index ["start_at", "end_at"], name: "index_holidays_on_start_at_and_end_at"
    t.index ["user_id"], name: "index_holidays_on_user_id"
  end

  create_table "releases", force: :cascade do |t|
    t.text "summary"
    t.date "released_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reporting_summaries", force: :cascade do |t|
    t.string "organisation", null: false
    t.boolean "four_week_availability", null: false
    t.date "first_available_slot_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "two_week_availability", default: false, null: false
    t.date "last_available_slot_on"
    t.date "last_slot_on"
    t.integer "total_slots_available"
    t.integer "total_slots_created"
    t.string "schedule_type", default: "pension_wise", null: false
  end

  create_table "schedules", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "start_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "slots", id: :serial, force: :cascade do |t|
    t.integer "schedule_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "day_of_week"
    t.integer "start_hour"
    t.integer "start_minute"
    t.integer "end_hour"
    t.integer "end_minute"
  end

  create_table "status_transitions", force: :cascade do |t|
    t.bigint "appointment_id"
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_status_transitions_on_appointment_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.boolean "remotely_signed_out", default: false
    t.boolean "disabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "permissions", default: "[]"
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.integer "casebook_guider_id"
    t.integer "casebook_location_id"
    t.string "schedule_type", default: "pension_wise", null: false
    t.index ["organisation_content_id"], name: "index_users_on_organisation_content_id"
    t.index ["permissions"], name: "index_users_on_permissions", using: :gin
    t.index ["schedule_type"], name: "index_users_on_schedule_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
