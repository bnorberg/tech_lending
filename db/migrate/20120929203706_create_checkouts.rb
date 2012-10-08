class CreateCheckouts < ActiveRecord::Migration
  def change
    create_table :checkouts do |t|
      t.primary_key :id
      t.integer :item_id
      t.date :date
      t.datetime :start_time
      t.datetime :end_time
      t.integer :duration
      t.string :patron_status
      t.string :patron_college
      t.integer :renewals

      t.timestamps
    end
  end
end
