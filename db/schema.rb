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

ActiveRecord::Schema[8.1].define(version: 2025_12_25_091135) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
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
    t.datetime "created_at", null: false
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

  create_table "bookings", force: :cascade do |t|
    t.string "booking_type", default: "business_created"
    t.bigint "business_id", null: false
    t.datetime "cancelled_at"
    t.datetime "completed_at"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "currency", default: "RSD"
    t.string "customer_email"
    t.bigint "customer_id"
    t.string "customer_name"
    t.string "customer_phone"
    t.datetime "end_time", null: false
    t.text "notes"
    t.integer "number_of_adults"
    t.integer "number_of_kids"
    t.bigint "pricing_plan_id"
    t.datetime "requested_at"
    t.text "special_requests"
    t.datetime "start_time", null: false
    t.string "status", default: "confirmed", null: false
    t.string "title", default: "", null: false
    t.decimal "total_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["booking_type"], name: "index_bookings_on_booking_type"
    t.index ["business_id", "start_time"], name: "index_bookings_on_business_id_and_start_time"
    t.index ["business_id"], name: "index_bookings_on_business_id"
    t.index ["customer_id"], name: "index_bookings_on_customer_id"
    t.index ["pricing_plan_id"], name: "index_bookings_on_pricing_plan_id"
    t.index ["status"], name: "index_bookings_on_status"
  end

  create_table "business_inquiries", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "contact_method"
    t.datetime "created_at", null: false
    t.string "inquiry_type"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_business_inquiries_on_business_id"
  end

  create_table "business_tags", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_business_tags_on_business_id"
    t.index ["tag_id"], name: "index_business_tags_on_tag_id"
  end

  create_table "business_views", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.string "referer"
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.index ["business_id"], name: "index_business_views_on_business_id"
  end

  create_table "businesses", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "address"
    t.bigint "category_id", null: false
    t.bigint "city_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.boolean "has_active_discount", default: false, null: false
    t.decimal "max_price", precision: 10, scale: 2
    t.decimal "min_price", precision: 10, scale: 2
    t.string "name", null: false
    t.string "phone"
    t.string "price_currency", default: "RSD", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "website"
    t.index ["active"], name: "index_businesses_on_active"
    t.index ["category_id"], name: "index_businesses_on_category_id"
    t.index ["city_id"], name: "index_businesses_on_city_id"
    t.index ["name"], name: "index_businesses_on_name"
    t.index ["user_id"], name: "index_businesses_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.boolean "active"
    t.string "color"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "cities", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "region"
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "last_message_at"
    t.datetime "updated_at", null: false
    t.index ["business_id", "customer_id"], name: "index_conversations_on_business_id_and_customer_id", unique: true
    t.index ["business_id"], name: "index_conversations_on_business_id"
    t.index ["customer_id"], name: "index_conversations_on_customer_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.decimal "amount_off", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.string "label"
    t.string "name"
    t.integer "percentage_off"
    t.bigint "pricing_plan_id", null: false
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.integer "usage_limit"
    t.integer "used_count", default: 0, null: false
    t.index ["active"], name: "index_discounts_on_active"
    t.index ["pricing_plan_id"], name: "index_discounts_on_pricing_plan_id"
    t.index ["starts_at", "ends_at"], name: "index_discounts_on_starts_at_and_ends_at"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "newsletter_subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_newsletter_subscriptions_on_email", unique: true
  end

  create_table "payment_details", force: :cascade do |t|
    t.text "account_owner_address"
    t.string "account_owner_name"
    t.string "bank_account_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_payment_details_on_user_id"
  end

  create_table "pricing_plans", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.decimal "base_price", precision: 10, scale: 2, null: false
    t.bigint "business_id", null: false
    t.integer "capacity_adults"
    t.integer "capacity_kids"
    t.datetime "created_at", null: false
    t.string "currency", default: "RSD", null: false
    t.text "description"
    t.integer "duration_minutes"
    t.integer "maximum_quantity"
    t.jsonb "metadata", default: {}, null: false
    t.integer "minimum_quantity"
    t.string "name", null: false
    t.integer "plan_type", default: 0, null: false
    t.string "price_unit"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_pricing_plans_on_active"
    t.index ["business_id"], name: "index_pricing_plans_on_business_id"
    t.index ["metadata"], name: "index_pricing_plans_on_metadata", using: :gin
    t.index ["plan_type"], name: "index_pricing_plans_on_plan_type"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "rating"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["business_id"], name: "index_reviews_on_business_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "icon"
    t.string "name", null: false
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name", default: "", null: false
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "businesses"
  add_foreign_key "bookings", "pricing_plans"
  add_foreign_key "bookings", "users", column: "customer_id"
  add_foreign_key "business_inquiries", "businesses"
  add_foreign_key "business_tags", "businesses"
  add_foreign_key "business_tags", "tags"
  add_foreign_key "business_views", "businesses"
  add_foreign_key "businesses", "categories"
  add_foreign_key "businesses", "cities"
  add_foreign_key "businesses", "users"
  add_foreign_key "conversations", "businesses"
  add_foreign_key "conversations", "users", column: "customer_id"
  add_foreign_key "discounts", "pricing_plans"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "payment_details", "users"
  add_foreign_key "pricing_plans", "businesses"
  add_foreign_key "reviews", "businesses"
  add_foreign_key "reviews", "users"
end
