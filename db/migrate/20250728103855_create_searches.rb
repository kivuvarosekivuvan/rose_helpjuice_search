class CreateSearches < ActiveRecord::Migration[8.0]
  def change
    create_table :searches do |t|
      t.string :query
      t.string :user_ip
      t.datetime :last_seen_at

      t.timestamps
    end
  end
end
