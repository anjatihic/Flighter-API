class CreateFlights < ActiveRecord::Migration[6.1]
  def change
    create_table :flights do |t|
      t.string :name, unique: true
      t.integer :no_of_seats, null: false
      t.integer :base_price
      t.datetime :departs_at
      t.datetime :arrives_at

      t.belongs_to :company, index: true, foreign_key: true

      t.timestamps
    end
  end
end
