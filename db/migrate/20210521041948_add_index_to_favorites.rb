class AddIndexToFavorites < ActiveRecord::Migration[6.0]
  def change
    add_index :favorites, [:user_id, :post_id], unique: true
  end
end
