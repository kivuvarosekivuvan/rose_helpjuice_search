class AddUserIpLastSeenIndexToSearches < ActiveRecord::Migration[8.0]
  def change
    add_index :searches, [:user_ip, :last_seen_at]
  end
end
