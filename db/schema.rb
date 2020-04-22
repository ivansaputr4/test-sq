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

ActiveRecord::Schema.define(version: 2020_04_21_144100) do

  create_table "booking_schedules", force: :cascade do |t|
    t.date "booking_date"
    t.integer "doctor_id"
    t.integer "schedule_session", limit: 2, default: 1
    t.integer "patient_id"
    t.integer "state", limit: 2, default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "booking_date", "schedule_session"], name: "idx_book_sche_doctor_id_and_booking_date_and_sche_session"
    t.index ["patient_id"], name: "index_booking_schedules_on_patient_id"
  end

  create_table "doctor_schedules", force: :cascade do |t|
    t.integer "day_of_week", limit: 2
    t.integer "schedule_session", limit: 2, default: 1
    t.integer "start_hour", limit: 2
    t.integer "end_hour", limit: 2
    t.integer "doctor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "day_of_week", "schedule_session"], name: "idx_doc_sche_doctor_id_and_day_of_week_and_sche_session"
  end

  create_table "doctors", force: :cascade do |t|
    t.string "name"
    t.integer "specialist", limit: 2, default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["specialist"], name: "index_doctors_on_specialist"
  end

  create_table "hospitals", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.integer "area", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area", "name"], name: "index_hospitals_on_area_and_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

end
