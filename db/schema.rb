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

ActiveRecord::Schema[7.0].define(version: 2026_06_02_185304) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "care_logs", force: :cascade do |t|
    t.bigint "plant_id", null: false
    t.integer "action_type"
    t.date "performed_at"
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plant_id"], name: "index_care_logs_on_plant_id"
  end

  create_table "care_parameters", force: :cascade do |t|
    t.bigint "plant_id", null: false
    t.integer "action_type"
    t.integer "interval_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plant_id"], name: "index_care_parameters_on_plant_id"
  end

  create_table "plants", force: :cascade do |t|
    t.string "name"
    t.string "plant_type"
    t.string "sun_exposure"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "species"
    t.string "nickname"
    t.index ["user_id"], name: "index_plants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "callmebot_phone"
    t.string "callmebot_api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "care_logs", "plants"
  add_foreign_key "care_parameters", "plants"
  add_foreign_key "plants", "users"
end
