namespace :db do
  desc "calculates duration of each checkout"
  task :duration => :environment do
  
      require 'time_diff'
      Item.all.each do |i|
        i.checkouts.each do |co|
          if !co.end_time.nil?
            timediff = Time.diff(co.end_time, co.start_time)
            c = Checkout.find_by_id(co.id)
            c.duration = timediff[:diff]
            c.save!
            puts "Record #{co.id} was update with difference of #{timediff[:diff]}"
          else
            puts "There is no end time"  
          end
         end    
      end    
       
  end
end
      