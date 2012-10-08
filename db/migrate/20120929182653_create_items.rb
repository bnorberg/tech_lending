class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.primary_key :id
      t.string :call_number
      t.string :name
      t.string :location

      t.timestamps
    end
  end
end
