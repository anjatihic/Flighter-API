class AddTokenColumn < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :token, :text
    add_index :users, :token, unique: true
  end
end
