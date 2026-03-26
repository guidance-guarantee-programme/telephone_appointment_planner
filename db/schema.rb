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

ActiveRecord::Schema[8.1].define(version: 2026_04_08_132740) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
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
    t.datetime "created_at", precision: nil, null: false
    t.string "message", default: "", null: false
    t.integer "owner_id"
    t.integer "prior_owner_id"
    t.datetime "resolved_at", precision: nil
    t.integer "resolver_id"
    t.string "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["appointment_id"], name: "index_activities_on_appointment_id"
    t.index ["type"], name: "index_activities_on_type"
  end

  create_table "appointments", id: :serial, force: :cascade do |t|
    t.boolean "accessibility_requirements", default: false, null: false
    t.string "address_line_one", default: "", null: false
    t.string "address_line_three", default: "", null: false
    t.string "address_line_two", default: "", null: false
    t.string "adjustments", default: "", null: false
    t.integer "agent_id", null: false
    t.string "attended_digital"
    t.datetime "batch_processed_at", precision: nil
    t.boolean "bsl_video", default: false, null: false
    t.string "cancelled_via", default: "", null: false
    t.integer "casebook_appointment_id"
    t.string "consent_address_line_one", default: "", null: false
    t.string "consent_address_line_three", default: "", null: false
    t.string "consent_address_line_two", default: "", null: false
    t.string "consent_county", default: "", null: false
    t.string "consent_postcode", default: "", null: false
    t.string "consent_town", default: "", null: false
    t.string "country_code", default: "GB", null: false
    t.string "county", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "data_subject_age"
    t.boolean "data_subject_consent_obtained", default: false, null: false
    t.date "data_subject_date_of_birth"
    t.string "data_subject_name", default: "", null: false
    t.date "date_of_birth"
    t.boolean "dc_pot_confirmed", default: true, null: false
    t.string "email"
    t.string "email_consent", default: "", null: false
    t.boolean "email_consent_form_required", default: false, null: false
    t.datetime "end_at", precision: nil, null: false
    t.boolean "extended_duration", default: false, null: false
    t.string "first_name", null: false
    t.string "gdpr_consent", default: "", null: false
    t.integer "guider_id", null: false
    t.string "last_name", null: false
    t.boolean "lloyds_signposted", default: false, null: false
    t.string "memorable_word", null: false
    t.string "mobile", default: ""
    t.boolean "ms_teams_call", default: false
    t.text "notes", default: ""
    t.string "nudge_confirmation", default: "", null: false
    t.string "nudge_eligibility_reason", default: "", null: false
    t.boolean "nudged", default: false, null: false
    t.string "online_rescheduling_reason", default: "", null: false
    t.string "other_reason", default: "", null: false
    t.string "pension_provider", default: "", null: false
    t.string "phone", null: false
    t.string "postcode", default: "", null: false
    t.boolean "power_of_attorney", default: false, null: false
    t.bigint "previous_guider_id"
    t.boolean "printed_consent_form_required", default: false, null: false
    t.datetime "processed_at", precision: nil
    t.integer "rebooked_from_id"
    t.string "referrer", default: "", null: false
    t.datetime "rescheduled_at", precision: nil
    t.string "rescheduling_reason", default: "", null: false
    t.string "rescheduling_route", default: "", null: false
    t.string "schedule_type", default: "pension_wise", null: false
    t.string "secondary_status", default: "", null: false
    t.boolean "small_pots", default: false, null: false
    t.boolean "smarter_signposted", default: false
    t.datetime "start_at", precision: nil, null: false
    t.integer "status", default: 0, null: false
    t.boolean "status_reminder_sent"
    t.boolean "third_party_booking", default: false, null: false
    t.string "town", default: "", null: false
    t.string "transferring_pension_to", default: "", null: false
    t.string "type_of_appointment", default: "", null: false
    t.string "unique_reference_number", default: "", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "welsh", default: false, null: false
    t.integer "where_you_heard", default: 0, null: false
    t.index "guider_id, tsrange(start_at, end_at)", name: "index_appointments_guider_id_tsrange_start_at_end_at", using: :gist
    t.index "tsrange(start_at, end_at)", name: "index_appointments_tsrange_start_at_end_at", using: :gist
    t.index ["guider_id", "start_at"], name: "index_appointments_guider_start_schedule_status", where: "(((schedule_type)::text = 'pension_wise'::text) AND (status <> ALL ('{6,7,8,9}'::integer[])))"
    t.index ["guider_id", "start_at"], name: "unique_slot_guider_in_appointment", unique: true, where: "((status <> ALL (ARRAY[5, 6, 7, 8, 9])) AND (start_at > '2024-01-01 00:00:00'::timestamp without time zone))"
    t.index ["guider_id"], name: "index_appointments_guider_schedule_status", where: "(((schedule_type)::text = 'pension_wise'::text) AND (status <> ALL ('{6,7,8,9}'::integer[])))"
    t.index ["guider_id"], name: "index_appointments_on_guider_id"
    t.index ["previous_guider_id"], name: "index_appointments_on_previous_guider_id"
    t.index ["schedule_type"], name: "index_appointments_on_schedule_type"
    t.index ["start_at", "end_at", "guider_id"], name: "index_appointments_on_start_at_and_end_at_and_guider_id"
    t.index ["start_at"], name: "index_appointments_on_start_at"
  end

  create_table "audits", id: :serial, force: :cascade do |t|
    t.string "action"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.text "audited_changes"
    t.string "comment"
    t.datetime "created_at", precision: nil
    t.string "remote_address"
    t.string "request_uuid"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.integer "version", default: 0
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "bookable_slots", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "end_at", precision: nil, null: false
    t.integer "guider_id", null: false
    t.string "schedule_type", default: "pension_wise", null: false
    t.datetime "start_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index "tsrange(start_at, end_at)", name: "index_bookable_slots_tsrange_start_at_end_at", using: :gist
    t.index ["guider_id"], name: "index_bookable_slots_on_guider_id"
    t.index ["schedule_type"], name: "index_bookable_slots_on_schedule_type"
    t.index ["start_at", "end_at"], name: "index_bookable_slots_on_start_at_and_end_at"
  end

  create_table "email_lookups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "organisation_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_assignments", id: false, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "user_id", null: false
    t.index ["group_id"], name: "index_group_assignments_on_group_id"
    t.index ["user_id"], name: "index_group_assignments_on_user_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name", default: "", null: false
    t.string "organisation_content_id", default: "", null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "holidays", id: :serial, force: :cascade do |t|
    t.boolean "all_day", default: false, null: false
    t.boolean "bank_holiday", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "end_at", precision: nil
    t.datetime "start_at", precision: nil
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index "tsrange(start_at, end_at)", name: "index_holidays_tsrange_start_at_end_at", using: :gist
    t.index "user_id, tsrange(start_at, end_at)", name: "index_holidays_userid_tsrange", using: :gist
    t.index ["start_at", "end_at"], name: "index_holidays_on_start_at_and_end_at"
    t.index ["user_id"], name: "index_holidays_on_user_id"
  end

  create_table "online_reschedules", force: :cascade do |t|
    t.bigint "appointment_id"
    t.datetime "created_at", null: false
    t.bigint "previous_guider_id"
    t.datetime "previous_start_at", null: false
    t.datetime "processed_at"
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_online_reschedules_on_appointment_id"
    t.index ["previous_guider_id"], name: "index_online_reschedules_on_previous_guider_id"
  end

  create_table "releases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "released_on"
    t.text "summary"
    t.datetime "updated_at", null: false
  end

  create_table "reporting_summaries", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.date "first_available_slot_on"
    t.boolean "four_week_availability", null: false
    t.date "last_available_slot_on"
    t.date "last_slot_on"
    t.string "organisation", null: false
    t.string "schedule_type", default: "pension_wise", null: false
    t.integer "total_slots_available"
    t.integer "total_slots_created"
    t.boolean "two_week_availability", default: false, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "schedules", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "start_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
  end

  create_table "slots", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "day_of_week"
    t.integer "end_hour"
    t.integer "end_minute"
    t.integer "schedule_id", null: false
    t.integer "start_hour"
    t.integer "start_minute"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "status_transitions", force: :cascade do |t|
    t.bigint "appointment_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "status", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["appointment_id"], name: "index_status_transitions_on_appointment_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "casebook_guider_id"
    t.integer "casebook_location_id"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "disabled", default: false
    t.string "email"
    t.string "genesys_agent_id"
    t.string "genesys_management_unit_id"
    t.string "name"
    t.string "organisation_content_id"
    t.string "organisation_slug"
    t.jsonb "permissions", default: "[]"
    t.integer "position", default: 0, null: false
    t.boolean "remotely_signed_out", default: false
    t.string "schedule_type", default: "pension_wise", null: false
    t.string "uid"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["organisation_content_id"], name: "index_users_on_organisation_content_id"
    t.index ["permissions"], name: "index_users_on_permissions", using: :gin
    t.index ["schedule_type"], name: "index_users_on_schedule_type"
  end

  create_table "vulnerability_profiles", force: :cascade do |t|
    t.bigint "appointment_id"
    t.boolean "approaching_later_life"
    t.boolean "being_diagnosed_with_a_health_condition"
    t.datetime "created_at", null: false
    t.boolean "dealing_with_bereavement"
    t.boolean "disability"
    t.boolean "falling_into_financial_difficulties"
    t.boolean "getting_married_or_becoming_civil_partners"
    t.boolean "mental_health_condition"
    t.boolean "moving_or_losing_a_home"
    t.boolean "partially_or_fully_retiring"
    t.boolean "separating_or_getting_divorced"
    t.boolean "starting_changing_or_losing_a_job"
    t.datetime "updated_at", null: false
    t.boolean "vulnerable_customer"
    t.index ["appointment_id"], name: "index_vulnerability_profiles_on_appointment_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
