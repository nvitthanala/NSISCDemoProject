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

ActiveRecord::Schema[8.1].define(version: 2026_04_14_062942) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "athletes", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "team"
    t.datetime "updated_at", null: false
  end

  create_table "race_results", force: :cascade do |t|
    t.bigint "athlete_id", null: false
    t.datetime "created_at", null: false
    t.date "date_swum"
    t.string "event_name"
    t.boolean "made_a_final"
    t.boolean "made_b_final"
    t.string "ncaa_status"
    t.integer "placement"
    t.string "round"
    t.float "time_seconds"
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_race_results_on_athlete_id"
  end

  create_table "standards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_name"
    t.string "organization"
    t.string "standard_type"
    t.float "target_time_seconds"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "race_results", "athletes"
end
