class AddColumnsToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :name, :string
    add_column :posts, :address, :string
    add_column :posts, :fee, :integer
    add_column :posts, :available_time, :string
    add_column :posts, :holiday, :string
    add_column :posts, :phone_number, :string
    add_column :posts, :url, :string
  end
end
