class ChangeActivatedOfUsers < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :activated, :boolean, default: false
  end

  def down
    change_column :users, :activated, :boolean
  end
end
