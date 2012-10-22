class Checkout < ActiveRecord::Base
  attr_accessible :date, :duration, :end_time, :id, :item_id, :patron_college, :patron_status, :renewals, :start_time, :transaction_id, :created_at, :updated_at
end
