class Item < ActiveRecord::Base
  attr_accessible :call_number, :id, :location, :name, :created_at, :updated_at
  has_many :checkouts
end
