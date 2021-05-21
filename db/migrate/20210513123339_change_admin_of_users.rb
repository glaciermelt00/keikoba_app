class ChangeAdminOfUsers < ActiveRecord::Migration[6.0]
  def up
    change_index :favorites, [:post_id], unique: true
    change_index :favorites, [:user_id], unique: true
  end

  def down 
    change_index :favorites, [:post_id]
    change_index :favorites, [:user_id]
  end
end
