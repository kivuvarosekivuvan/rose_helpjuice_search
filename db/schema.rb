ActiveRecord::Schema[8.0].define(version: 2025_07_28_104915) do
  enable_extension "pg_catalog.plpgsql"

  create_table "searches", force: :cascade do |t|
    t.string "query"
    t.string "user_ip"
    t.datetime "last_seen_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_ip", "last_seen_at"], name: "index_searches_on_user_ip_and_last_seen_at"
  end
end
