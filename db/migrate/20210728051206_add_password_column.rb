class AddPasswordColumn < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :password_digest, :text
    User.all.update(password: 'pass')
  end

  def down
    remove_column :users, :password_digest
  end
end
