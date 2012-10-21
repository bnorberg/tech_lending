class Item < ActiveRecord::Base
  attr_accessible :call_number, :id, :location, :name
  has_many :checkouts
  
  def self.get_item_call_number
      @cns = []
      Item.all.each do |item|
        @cns << item.call_number 
      end
      @cns.uniq.sort
   end
  
   def self.get_patron_status
      @statuses = []
        Item.all.each do |item|
            if !item.checkouts.empty?
            item.checkouts.each do |co|
              @statuses << co.patron_status
            end
          end  
        end
        @statuses.uniq.sort
    end
    
    def self.get_patron_college
       @colleges = []
        Item.all.each do |item|
          if !item.checkouts.empty?
          item.checkouts.each do |co|
            @colleges << co.patron_college
            end
          end  
        end
        @colleges.uniq.sort
     end
  
end
