class AddTranscationidToCheckouts < ActiveRecord::Migration
  def change
    add_column :checkouts, :transcation_id, :string
  end
end
