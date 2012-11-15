class Checkout < ActiveRecord::Base
  attr_accessible :date, :duration, :end_time, :id, :item_id, :patron_college, :patron_status, :renewals, :start_time, :transaction_id, :call_number, :created_at, :updated_at
  
  def self.total_on(date)
      where("date(date) = ?",date).count
    end 
    
    def self.status_total(status)
      where("patron_status = ?", status).count
    end  
    
    def self.college_total(college)
      where("patron_college = ?", college).count
    end
end
