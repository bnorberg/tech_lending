class AddCallNumberToCheckouts < ActiveRecord::Migration
  def change
    add_column :checkouts, :call_number, :string
  end
end
