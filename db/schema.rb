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

ActiveRecord::Schema.define(version: 20150315072953) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "snippets", force: true do |t|
    t.text     "audio_url"
    t.text     "reference"
    t.text     "status",     default: "Active"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "from"
  end

  create_table "users", force: true do |t|
    t.text     "first_name"
    t.text     "last_name"
    t.text     "email"
    t.text     "password_hash"
    t.text     "password_salt"
    t.boolean  "email_verification", default: false
    t.text     "verification_code"
    t.text     "api_authtoken"
    t.datetime "authtoken_expiry"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
