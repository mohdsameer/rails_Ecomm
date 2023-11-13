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

ActiveRecord::Schema[7.0].define(version: 2023_11_13_105659) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "fullname"
    t.string "lastname"
    t.string "country"
    t.string "state"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "zipcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "shippo_address_id"
    t.string "num"
    t.integer "addressable_id"
    t.string "addressable_type"
  end

  create_table "assign_details", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "order_id"
    t.decimal "price_per_design"
    t.decimal "price_for_total"
    t.datetime "due_date"
    t.string "additional_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_assign_details_on_order_id"
    t.index ["user_id"], name: "index_assign_details_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "from"
    t.integer "to"
    t.string "review_message"
    t.bigint "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_messages_on_order_id"
  end

  create_table "order_products", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "order_id"
    t.integer "product_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "variant_id"
    t.integer "user_id"
    t.index ["order_id"], name: "index_order_products_on_order_id"
    t.index ["product_id"], name: "index_order_products_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "customer_name"
    t.float "price", default: 2.5
    t.integer "order_status", default: 0
    t.integer "order_edit_status", default: 0
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "priority", default: 0
    t.string "reject_reason"
    t.string "additional_comment"
    t.bigint "user_id"
    t.string "revision_info"
    t.boolean "request_revision", default: false
    t.string "etsy_order_id"
    t.bigint "shipping_method_id"
    t.boolean "dimensions_is_manual", default: false
    t.decimal "custom_length"
    t.decimal "custom_height"
    t.decimal "custom_width"
    t.decimal "custom_weight_lb"
    t.decimal "custom_weight_oz"
    t.string "shippo_rate_id"
    t.string "shippo_shipment_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "producers_variants", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "variant_id"
    t.integer "inventory"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_producers_variants_on_user_id"
    t.index ["variant_id"], name: "index_producers_variants_on_variant_id"
  end

  create_table "product_producer_pricings", force: :cascade do |t|
    t.float "blank_price", default: 0.0
    t.float "front_side_print_price", default: 0.0
    t.float "back_side_print_price", default: 0.0
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_producer_pricings_on_product_id"
    t.index ["user_id"], name: "index_product_producer_pricings_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "brand_name"
    t.string "name"
    t.bigint "print_area_width"
    t.bigint "print_area_height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.string "type"
    t.integer "status", default: 0
    t.bigint "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cancel_reason"
    t.index ["order_id"], name: "index_requests_on_order_id"
  end

  create_table "senders", force: :cascade do |t|
    t.bigint "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_senders_on_order_id"
  end

  create_table "shipping_labels", force: :cascade do |t|
    t.bigint "product_id"
    t.integer "item_quantity_min"
    t.integer "item_quantity_max"
    t.decimal "length"
    t.decimal "height"
    t.decimal "width"
    t.decimal "weight_lb"
    t.decimal "weight_oz"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_shipping_labels_on_product_id"
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.string "name"
    t.string "partner"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "min_day"
    t.integer "max_day"
  end

  create_table "shippo_labels", force: :cascade do |t|
    t.bigint "order_id"
    t.string "shippo_rate_id"
    t.string "shippo_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_shippo_labels_on_order_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.string "email", null: false
    t.string "password_digest"
    t.string "company_name"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "etsy_access_token"
    t.string "etsy_refresh_token"
  end

  create_table "variants", force: :cascade do |t|
    t.integer "product_id"
    t.jsonb "specification", default: "{}", null: false
    t.string "color"
    t.integer "size"
    t.integer "inventory"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "length"
    t.float "height"
    t.float "width"
    t.float "weight_lb"
    t.float "weight_oz"
    t.string "inventory_reason"
    t.string "design_style"
    t.string "font"
    t.string "text"
    t.string "real_variant_sku"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assign_details", "orders"
  add_foreign_key "assign_details", "users"
  add_foreign_key "messages", "orders"
  add_foreign_key "order_products", "orders"
  add_foreign_key "order_products", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "producers_variants", "users"
  add_foreign_key "producers_variants", "variants"
  add_foreign_key "product_producer_pricings", "products"
  add_foreign_key "product_producer_pricings", "users"
  add_foreign_key "requests", "orders"
end
