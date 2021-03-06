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

ActiveRecord::Schema.define(version: 20170602171318) do

  create_table "travels", force: :cascade do |t|
    t.string "pnr", null: false
    t.string "ticket_number", null: false
    t.string "origin"
    t.string "destination"
    t.date "departure_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tries", default: 0
    t.datetime "last_try_refund_at"
    t.boolean "eligible", default: false
    t.index ["pnr", "ticket_number"], name: "index_travels_on_pnr_and_ticket_number", unique: true
  end

end
