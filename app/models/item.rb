class Item < ActiveRecord::Base
  attr_accessible :call_number, :id, :location, :name
  has_many :checkouts
end
