class AddTranscationidToCheckouts < ActiveRecord::Migration
  def change
    add_column :checkouts, :transaction_id, :string
  end
end
