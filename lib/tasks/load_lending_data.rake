namespace :db do
  desc "load latest tech lending data from csv"
  task :load => :environment do
  
      require 'csv'
      require 'date'
      
      def get_date(date)
        d = date[1..8]
        date = Date.parse(d) 
        date
      end 
      
      def get_month(date)
        d = date[1..8]
        date = Date.parse(d) 
        month = Date::MONTHNAMES[date.month]
        month
      end
      
      def get_year(date)
        d = date[1..8]
        date = Date.parse(d) 
        year = date.year
        year
      end
      
      def get_name(n)
        name = n.split('#')[0].split('IQ')[1]
        name
      end  
      
      def get_status(s)
        if s.include? '-'
          status = s.split('-')[1]
        else
          status = s.delete('PG')
        end    
        status
      end  
      
      def get_time(t)
        time =  t[1..12]
        datetime = DateTime.parse(time).to_datetime.to_s
        just_time = Time.parse(datetime)
        just_time
      end  
      
      @filename = ENV["FILE_PATH"].split("/").last
      @rejected_filenames = @filename.sub(".txt", "")
      load_errors_dir = File.join(Rails.root, "/tmp", "/load_errors" "/#{@rejected_filenames}_rejected_files.txt")
      @errors = File.new("#{load_errors_dir}", "w")
      file = File.new("#{ENV["FILE_PATH"]}", "r")
      file.each do |l|
        begin 
          @the_line = l
          line = CSV.parse_line(@the_line, {:col_sep => '^', :encoding => 'n'})
          if line[1].match /^S\d\dCV.*\z/
           if line[5] == 'UTCHECKEDOUT'
             if line[7].match /^UB.*\z/
               @record = Item.find_by_call_number(line[8])
               puts @record.inspect
               if line[4] == 'PEGRAD'
                 if @record.nil?
                   @i = Item.create(:call_number => line[8], :name => get_name(line[8]),:location => line[6]) 
                   @i.created_at = Time.now.strftime('%B %Y')
                   @i.updated_at = Time.now
                   @i.save
                   co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => line[4].delete('PE'), :patron_college => line[3], :renewals => 0)
                   co.created_at = Time.now.strftime('%B %Y')
                   co.updated_at = Time.now
                   co.save      
                 else
                   @co = Checkout.find_by_transaction_id(line[0])
                   if @co.nil?
                     co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                      :patron_status => line[4].delete('PE'), :patron_college => line[3], :renewals => 0)
                     co.created_at = Time.now.strftime('%B %Y')
                     co.updated_at = Time.now
                     co.save
                    else
                      puts "The record #{@the_line} already exists. No records were created."
                    end   
                 end
               elsif line[2].include? 'PGTRLN'
                 if @record.nil?
                    @i = Item.create(:call_number => line[8], :name => get_name(line[8]),:location => line[6]) 
                    @i.created_at = Time.now.strftime('%B %Y')
                    @i.updated_at = Time.now
                    @i.save
                    co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                           :patron_status => line[4].delete('PE'), :patron_college => get_status(line[2]), :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save      
                  else
                    @co = Checkout.find_by_transaction_id(line[0])
                     if @co.nil?
                       co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                       :patron_status => line[4].delete('PE'), :patron_college => get_status(line[2]), :renewals => 0)
                       co.created_at = Time.now.strftime('%B %Y')
                       co.updated_at = Time.now
                       co.save
                     else
                       puts "The record #{@the_line} already exists. No records were created."
                     end      
                  end
               else
                 if line[3] == 'UJDELINQUENT'
                   if @record.nil?
                     @i = Item.create(:call_number => line[8], :name => get_name(line[8]),:location => line[6]) 
                     @i.created_at = Time.now.strftime('%B %Y')
                     @i.updated_at = Time.now
                     @i.save
                     if line[2] == 'PGNCSUSTAFF'
                       co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                              :patron_status => line[2].delete('PG'), :patron_college => 'N/A', :renewals => 0)
                       co.created_at = Time.now.strftime('%B %Y')
                       co.updated_at = Time.now
                       co.save
                     elsif line[2] == 'PHVISNOPAY' 
                      if line[5] == 'PESTAFF' 
                       co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                 :patron_status => line[5].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                       co.created_at = Time.now.strftime('%B %Y')
                       co.updated_at = Time.now
                       co.save 
                      elsif line[5] == 'PEGRAD'
                        co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                  :patron_status => line[5].delete('PE'), :patron_college => line[4], :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save
                      end
                     else
                       co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                       co.created_at = Time.now.strftime('%B %Y')
                       co.updated_at = Time.now
                       co.save
                     end          
                   else
                     @co = Checkout.find_by_transaction_id(line[0])
                     if @co.nil?
                       if line[2] == 'PGNCSUSTAFF'
                         co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                 :patron_status => line[2].delete('PG'), :patron_college => 'N/A', :renewals => 0)
                         co.created_at = Time.now.strftime('%B %Y')
                         co.updated_at = Time.now
                         co.save
                       elsif line[2] == 'PHVISNOPAY'
                         if line[5] == 'PESTAFF' 
                           co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                  :patron_status => line[5].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                           co.created_at = Time.now.strftime('%B %Y')
                           co.updated_at = Time.now
                           co.save 
                         elsif line[5] == 'PEGRAD'
                           co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                   :patron_status => line[5].delete('PE'), :patron_college => line[4], :renewals => 0)
                           co.created_at = Time.now.strftime('%B %Y')
                           co.updated_at = Time.now
                           co.save
                         end 
                       elsif line[2] == 'PGTRLN-NCCU'
                           co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                    :patron_status => line[4].delete('PE'), :patron_college => get_status(line[2]), :renewals => 0)
                           co.created_at = Time.now.strftime('%B %Y')
                           co.updated_at = Time.now
                           co.save       
                       else
                         co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                   :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                         co.created_at = Time.now.strftime('%B %Y')
                         co.updated_at = Time.now
                         co.save
                       end
                     else
                       puts "The record #{@the_line} already exists. No records were created."
                     end    
                   end
                 else   
                   if line[4] == 'PEUNDERGRAD'
                     if @record.nil?
                        @i = Item.create(:call_number => line[8], :name => get_name(line[8]),:location => line[6]) 
                        @i.created_at = Time.now.strftime('%B %Y')
                        @i.updated_at = Time.now
                        @i.save
                        if line[2].include? '-'
                          co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                               :patron_status => line[4].sub('PE', ''), :patron_college => 'N/A', :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save  
                        else
                          co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                    :patron_status => line[4].sub('PE', ''), :patron_college => 'N/A', :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save
                        end      
                     else
                       @co = Checkout.find_by_transaction_id(line[0])
                        if @co.nil?
                          if line[2].include? '-'
                            co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                    :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                            co.created_at = Time.now.strftime('%B %Y')
                            co.updated_at = Time.now
                            co.save
                          else
                            co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                       :patron_status => line[4].sub('PE', ''), :patron_college => line[3], :renewals => 0)
                            co.created_at = Time.now.strftime('%B %Y')
                            co.updated_at = Time.now
                            co.save
                          end
                        else  
                          puts "The record #{@the_line} already exists. No records were created." 
                        end
                     end  
                   else    
                    if @record.nil?
                      @i = Item.create(:call_number => line[8], :name => get_name(line[8]),:location => line[6]) 
                      @i.created_at = Time.now.strftime('%B %Y')
                      @i.updated_at = Time.now
                      @i.save
                      if line[2].include? '-'
                        co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                            :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save  
                      else
                        co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                               :patron_status => line[4].delete('PE'), :patron_college => line[3], :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save
                      end      
                    else
                      @co = Checkout.find_by_transaction_id(line[0])
                      if @co.nil?
                        if line[2].include? '-'
                          co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                               :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save  
                        else
                          co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                  :patron_status => line[4].delete('PE'), :patron_college => line[3], :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save
                        end
                      else
                        puts "The record #{@the_line} already exists. No records were created."
                      end    
                    end
                  end  
                end 
               end
             else
               @record = Item.find_by_call_number(line[7])
               puts @record.inspect
               if line[4] == 'PECIRCSTUD'
                 if @record.nil?
                    @i = Item.create(:call_number => line[7], :name => get_name(line[7]),:location => line[6]) 
                    @i.created_at = Time.now.strftime('%B %Y')
                    @i.updated_at = Time.now
                    @i.save
                    co = @i.checkouts.create(:transaction_id => line[0],:date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                         :patron_status => 'Test Circ', :patron_college => 'N/A', :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save      
                 else
                   @co = Checkout.find_by_transaction_id(line[0])
                   if @co.nil?
                      co = Checkout.create(:transaction_id => line[0],:item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                       :patron_status => 'Test Circ', :patron_college => 'N/A', :renewals => 0)
                      co.created_at = Time.now.strftime('%B %Y')
                      co.updated_at = Time.now
                      co.save
                   else
                     puts "The record #{@the_line} already exists. No records were created."
                   end   
                 end
               else  
                 if line[4] == 'PEGRAD'
                   if @record.nil?
                     @i = Item.create(:call_number => line[7], :name => get_name(line[7]),:location => line[6]) 
                     @i.created_at = Time.now.strftime('%B %Y')
                     @i.updated_at = Time.now
                     @i.save
                     co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => line[4].delete('PE'), :patron_college => line[3], :renewals => 0)
                     co.created_at = Time.now.strftime('%B %Y')
                     co.updated_at = Time.now
                     co.save      
                   else
                     @co = Checkout.find_by_transaction_id(line[0])
                      if @co.nil?
                         co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => line[4].delete('PE'), :patron_college => line[3], :renewals => 0)
                         co.created_at = Time.now.strftime('%B %Y')
                         co.updated_at = Time.now
                         co.save
                      else
                          puts "The record #{@the_line} already exists. No records were created."
                      end
                   end
                 elsif line[4] == 'PESTAFF'
                   if @record.nil?
                      @i = Item.create(:call_number => line[7], :name => get_name(line[7]),:location => line[6]) 
                      @i.created_at = Time.now.strftime('%B %Y')
                      @i.updated_at = Time.now
                      @i.save
                      co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                           :patron_status => line[4].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                      co.created_at = Time.now.strftime('%B %Y')
                      co.updated_at = Time.now
                      co.save      
                    else
                      @co = Checkout.find_by_transaction_id(line[0])
                      if @co.nil?
                        co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                         :patron_status => line[4].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save
                      else
                        puts "The record #{@the_line} already exists. No records were created."
                      end  
                    end
                 elsif line[4] == 'PEUNDERGRAD'
                    if @record.nil?
                      @i = Item.create(:call_number => line[7], :name => get_name(line[7]),:location => line[6]) 
                      @i.created_at = Time.now.strftime('%B %Y')
                      @i.updated_at = Time.now
                      @i.save
                      co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                             :patron_status => line[4].delete('PE'), :patron_college => line[3], :renewals => 0)
                      co.created_at = Time.now.strftime('%B %Y')
                      co.updated_at = Time.now
                      co.save      
                    else
                      @co = Checkout.find_by_transaction_id(line[0])
                      if @co.nil?
                        co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                           :patron_status => line[4].delete('PE'), :patron_college => line[3], :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save
                      else
                        puts "The record #{@the_line} already exists. No records were created."
                      end
                    end  
                 end
               end       
             end      
           elsif line[6] == 'UTCHECKEDOUT'
            if line[8].include? 'AIR' or line[8].include? '45W'
              @record = Item.find_by_call_number(line[8])
               puts @record.inspect
               if @record.nil?
                 @i = Item.create(:call_number => line[8], :name => get_name(line[8]),:location => line[7])
                 @i.created_at = Time.now.strftime('%B %Y')
                 @i.updated_at = Time.now
                 @i.save
                 co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                 :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                 co.created_at = Time.now.strftime('%B %Y')
                 co.updated_at = Time.now
                 co.save 
               else
                 @co = Checkout.find_by_transaction_id(line[0])
                 if @co.nil?
                   co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                           :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                   co.created_at = Time.now.strftime('%B %Y')
                   co.updated_at = Time.now
                   co.save
                 else
                   puts "The record #{@the_line} already exists. No records were created."
                 end
               end  
            else
              if line[8].match /^UB.*\z/
                @record = Item.find_by_call_number(line[9])
                puts @record.inspect
                if line[5] == 'PEFACULTY' or line[5] == 'PESTAFF'
                  if @record.nil?
                     @i = Item.create(:call_number => line[9], :name => get_name(line[9]),:location => line[7])
                     @i.created_at = Time.now.strftime('%B %Y')
                     @i.updated_at = Time.now
                     @i.save
                     co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                               :patron_status => line[5].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                     co.created_at = Time.now.strftime('%B %Y')
                     co.updated_at = Time.now
                     co.save 
                   else
                     @co = Checkout.find_by_transaction_id(line[0])
                     if @co.nil?
                       co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                           :patron_status => line[5].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                       co.created_at = Time.now.strftime('%B %Y')
                       co.updated_at = Time.now
                       co.save
                    else
                       puts "The record #{@the_line} already exists. No records were created."
                    end  
                  end
                elsif line[5] == 'PEUNDERGRAD'
                  if line[2] == 'P4PROTECT'
                    if @record.nil?
                      @i = Item.create(:call_number => line[9], :name => get_name(line[9]),:location => line[7])
                      @i.created_at = Time.now.strftime('%B %Y')
                      @i.updated_at = Time.now
                      @i.save
                      co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                :patron_status => line[5].sub('PE', ''), :patron_college => line[4], :renewals => 0)
                      co.created_at = Time.now.strftime('%B %Y')
                      co.updated_at = Time.now
                      co.save 
                    else
                      @co = Checkout.find_by_transaction_id(line[0])
                      if @co.nil?
                        co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                            :patron_status => line[5].sub('PE', ''), :patron_college => line[4], :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save
                      else
                        puts "The record #{@the_line} already exists. No records were created."
                      end
                    end
                  else
                    if line[2] == 'PHNCSU-DIST'
                      if @record.nil?
                        @i = Item.create(:call_number => line[9], :name => get_name(line[9]),:location => line[7])
                        @i.created_at = Time.now.strftime('%B %Y')
                        @i.updated_at = Time.now
                        @i.save
                        co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                  :patron_status => line[2].delete('PH'), :patron_college => line[4], :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save 
                      else
                        @co = Checkout.find_by_transaction_id(line[0])
                        if @co.nil?
                          co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                              :patron_status => line[2].delete('PH'), :patron_college => line[4], :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save
                        else
                          puts "The record #{@the_line} already exists. No records were created."
                        end
                      end 
                    else      
                      if @record.nil?
                        @i = Item.create(:call_number => line[9], :name => get_name(line[9]),:location => line[7])
                        @i.created_at = Time.now.strftime('%B %Y')
                        @i.updated_at = Time.now
                        @i.save
                        co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                              :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save 
                      else
                        @co = Checkout.find_by_transaction_id(line[0])
                        if @co.nil?
                          co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save
                        else
                          puts "The record #{@the_line} already exists. No records were created."
                        end
                      end  
                    end
                  end  
                elsif line[2] == 'PHVISNOPAY' or line[2] == 'PHNOPAY'
                   if @record.nil?
                     @i = Item.create(:call_number => line[9], :name => get_name(line[9]),:location => line[7])
                     @i.created_at = Time.now.strftime('%B %Y')
                     @i.updated_at = Time.now
                     @i.save
                     co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                               :patron_status => line[5].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                     co.created_at = Time.now.strftime('%B %Y')
                     co.updated_at = Time.now
                     co.save 
                   else
                     @co = Checkout.find_by_transaction_id(line[0])
                     if @co.nil?
                       co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                           :patron_status => line[5].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                       co.created_at = Time.now.strftime('%B %Y')
                       co.updated_at = Time.now
                       co.save
                     else
                       puts "The record #{@the_line} already exists. No records were created."
                     end
                   end
                else
                 if line[2] == 'PHNCSU-DIST' or line[3] == 'PHNCSU-DIST'
                   if @record.nil?
                     @i = Item.create(:call_number => line[9], :name => get_name(line[9]),:location => line[7])
                     @i.created_at = Time.now.strftime('%B %Y')
                     @i.updated_at = Time.now
                     @i.save
                     if line[5] == 'PEGRAD'
                       co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                 :patron_status => "#{line[5].delete('PE') + '-' + line[2].delete('PH')}", :patron_college => line[4], :renewals => 0)
                       co.created_at = Time.now.strftime('%B %Y')
                       co.updated_at = Time.now
                       co.save 
                     else
                       co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                   :patron_status => "#{line[3].delete('PH') + '-' + get_status(line[2])}", :patron_college => line[5], :renewals => 0)
                       co.created_at = Time.now.strftime('%B %Y')
                       co.updated_at = Time.now
                       co.save
                     end      
                   else
                     @co = Checkout.find_by_transaction_id(line[0])
                     if @co.nil?
                       if line[5] == 'PEGRAD'
                          co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                    :patron_status => "#{line[5].delete('PE') + '-' + line[2].delete('PH')}", :patron_college => line[4], :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save 
                       else
                          co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                      :patron_status => "#{line[3].delete('PH') + '-' + get_status(line[2])}", :patron_college => line[5], :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save
                       end
                     else
                        puts "The record #{@the_line} already exists. No records were created."
                     end
                   end 
                 else    
                  if @record.nil?
                   @i = Item.create(:call_number => line[9], :name => get_name(line[9]),:location => line[7])
                   @i.created_at = Time.now.strftime('%B %Y')
                   @i.updated_at = Time.now
                   @i.save
                   if line[5] == 'PESPECUG' or line[5] == 'PEGRAD'
                     co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                               :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                     co.created_at = Time.now.strftime('%B %Y')
                     co.updated_at = Time.now
                     co.save
                   elsif line[5] == 'PESTAFF'
                      co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                   :patron_status => line[2].delete('PH'), :patron_college => 'N/A', :renewals => 0)
                      co.created_at = Time.now.strftime('%B %Y')
                      co.updated_at = Time.now
                      co.save
                   else
                      co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                     :patron_status => line[5].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                      co.created_at = Time.now.strftime('%B %Y')
                      co.updated_at = Time.now
                      co.save
                   end
                  else
                   @co = Checkout.find_by_transaction_id(line[0])
                   if @co.nil?
                     if line[5] == 'PESPECUG' or line[5] == 'PEGRAD'
                       co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                  :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save
                     elsif line[5] == 'PESTAFF'
                        co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                       :patron_status => line[2].delete('PH'), :patron_college => 'N/A', :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save  
                     else
                        co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                    :patron_status => line[5].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save
                     end
                   else
                      puts "The record #{@the_line} already exists. No records were created."
                   end    
                  end
                 end
                end  
              else
                 @record = Item.find_by_call_number(line[8])
                 puts @record.inspect
                 if @record.nil?
                   @i = Item.create(:call_number => line[8], :name => get_name(line[8]),:location => line[7])
                   @i.created_at = Time.now.strftime('%B %Y')
                   @i.updated_at = Time.now
                   @i.save
                   co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                     :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                   co.created_at = Time.now.strftime('%B %Y')
                   co.updated_at = Time.now
                   co.save 
                 else
                   @co = Checkout.find_by_transaction_id(line[0])
                   if @co.nil?
                     co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                                   :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                     co.created_at = Time.now.strftime('%B %Y')
                     co.updated_at = Time.now
                     co.save
                   else
                     puts "The record #{@the_line} already exists. No records were created."
                   end
                 end  
              end   
            end  
           elsif line[7] == 'UTCHECKEDOUT'
            if line[3] == 'PHVISNOPAY' or line[4] == 'UJDELINQUENT'
              @record = Item.find_by_call_number(line[10])
              puts @record.inspect
              if @record.nil?
                @i = Item.create(:call_number => line[10], :name => get_name(line[10]),:location => line[8])
                @i.created_at = Time.now.strftime('%B %Y')
                @i.updated_at = Time.now
                @i.save
                if line[6] == 'PEUNDERGRAD'
                  if line[3] == 'PHNCSU-DIST'
                    co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                            :patron_status => "#{line[3].delete('PH') + '-' + get_status(line[2])}", :patron_college => line[5], :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save
                  else  
                    co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => get_status(line[2]), :patron_college => 'N/A', :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save
                  end  
                elsif line[6] == 'PEFACULTY'
                    co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                            :patron_status => line[6].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save   
                elsif line[3] == 'PHSTAFF'
                  if line[2].include? 'PGNCSU'
                    co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => get_status(line[2]), :patron_college => 'N/A', :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save
                  else  
                    co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => line[2].delete('PG'), :patron_college => 'N/A', :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save
                  end
                elsif line[3] == 'PHNCSU-DIST'
                  co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => "#{line[3].delete('PH') + '-' + get_status(line[2])}", :patron_college => line[5], :renewals => 0)
                  co.created_at = Time.now.strftime('%B %Y')
                  co.updated_at = Time.now
                  co.save 
                elsif line[2] == 'PHSTAFF'
                  co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => line[2].delete('PH'), :patron_college => 'N/A', :renewals => 0)
                  co.created_at = Time.now.strftime('%B %Y')
                  co.updated_at = Time.now
                  co.save
                elsif line[3] == 'P4PROTECT' or line[3] == 'PHVISNOPAY'
                  co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => get_status(line[2]), :patron_college => line[5], :renewals => 0)
                  co.created_at = Time.now.strftime('%B %Y')
                  co.updated_at = Time.now
                  co.save 
                else
                  co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => get_status(line[2]), :patron_college => 'N/A', :renewals => 0)
                  co.created_at = Time.now.strftime('%B %Y')
                  co.updated_at = Time.now
                  co.save
                end      
              else
                @co = Checkout.find_by_transaction_id(line[0])
                if @co.nil?
                  if line[6] == 'PEUNDERGRAD'
                    co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                      :patron_status => get_status(line[2]), :patron_college => 'N/A', :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save
                  elsif line[6] == 'PEFACULTY'
                      co = Checkout.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                              :patron_status => line[6].delete('PE'), :patron_college => 'N/A', :renewals => 0)
                      co.created_at = Time.now.strftime('%B %Y')
                      co.updated_at = Time.now
                      co.save  
                  elsif line[3] == 'PHSTAFF'
                    co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                            :patron_status => get_status(line[2]), :patron_college => 'N/A', :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save
                  elsif line[3] == 'P4PROTECT' or line[3] == 'PHVISNOPAY'
                    co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                            :patron_status => get_status(line[2]), :patron_college => line[5], :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save  
                  elsif line[3] == 'PHNCSU-DIST'
                    co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                              :patron_status => "#{line[3].delete('PH') + '-' + get_status(line[2])}", :patron_college => line[5], :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save
                  else
                    co = Checkout.create(:item_id => @record.id, :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                            :patron_status => get_status(line[2]), :patron_college => 'N/A', :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save
                  end
                else
                   puts "The record #{@the_line} already exists. No records were created."
                end        
              end
            else  
              @record = Item.find_by_call_number(line[10])
              puts @record.inspect
              if line[3] == 'PHNCSU-DIST'
                if @record.nil?
                  @i = Item.create(:call_number => line[10], :name => get_name(line[10]),:location => line[8])
                  @i.created_at = Time.now.strftime('%B %Y')
                  @i.updated_at = Time.now
                  @i.save
                  co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => "#{line[3].delete('PH') + '-' + get_status(line[2])}", :patron_college => line[5], :renewals => 0)
                  co.created_at = Time.now.strftime('%B %Y')
                  co.updated_at = Time.now
                  co.save 
                else
                  @co = Checkout.find_by_transaction_id(line[0])
                  if @co.nil?
                    co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                      :patron_status => "#{line[3].delete('PH') + '-' + get_status(line[2])}", :patron_college => line[5], :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save
                  else
                    puts "The record #{@the_line} already exists. No records were created."
                  end
                end
              else
                if line[3] == 'PHUNDERGRAD' or line[3] == 'PHSTAFF'
                  if @record.nil?
                    @i = Item.create(:call_number => line[10], :name => get_name(line[10]),:location => line[8])
                    @i.created_at = Time.now.strftime('%B %Y')
                    @i.updated_at = Time.now
                    @i.save
                    co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => get_status(line[2]), :patron_college => line[5], :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save 
                  else
                    @co = Checkout.find_by_transaction_id(line[0])
                    if @co.nil?
                      co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                      :patron_status => get_status(line[2]), :patron_college => line[5], :renewals => 0)
                      co.created_at = Time.now.strftime('%B %Y')
                      co.updated_at = Time.now
                      co.save
                    else
                      puts "The record #{@the_line} already exists. No records were created."
                    end
                  end
                else
                  if line[2] == 'PHPOSTDOC'
                    if @record.nil?
                      @i = Item.create(:call_number => line[10], :name => get_name(line[10]),:location => line[8])
                      @i.created_at = Time.now.strftime('%B %Y')
                      @i.updated_at = Time.now
                      @i.save
                      co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => "#{line[6].delete('PE') + '-' + line[2].sub('PH', '')}", :patron_college => 'N/A', :renewals => 0)
                      co.created_at = Time.now.strftime('%B %Y')
                      co.updated_at = Time.now
                      co.save 
                    else
                      @co = Checkout.find_by_transaction_id(line[0])
                      if @co.nil?
                        co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                      :patron_status => "#{line[6].delete('PE') + '-' + line[2].sub('PH', '')}", :patron_college => 'N/A', :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save
                      else
                        puts "The record #{@the_line} already exists. No records were created."
                      end
                    end
                  elsif line[3] == 'P4PROTECT'
                    if line[6] == 'PESPECUG'      
                      if @record.nil?
                        @i = Item.create(:call_number => line[10], :name => get_name(line[10]),:location => line[8])
                        @i.created_at = Time.now.strftime('%B %Y')
                        @i.updated_at = Time.now
                        @i.save
                        co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => get_status(line[2]), :patron_college => line[5], :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save 
                      else
                        @co = Checkout.find_by_transaction_id(line[0])
                        if @co.nil?
                          co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                      :patron_status => get_status(line[2]), :patron_college => line[5], :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save
                        else
                          puts "The record #{@the_line} already exists. No records were created."
                        end
                      end
                    else
                      if @record.nil?
                        @i = Item.create(:call_number => line[10], :name => get_name(line[10]),:location => line[8])
                        @i.created_at = Time.now.strftime('%B %Y')
                        @i.updated_at = Time.now
                        @i.save
                        co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => line[2].delete('PH'), :patron_college => 'N/A', :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save 
                      else
                        @co = Checkout.find_by_transaction_id(line[0])
                        if @co.nil?
                          co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                      :patron_status => line[2].delete('PH'), :patron_college => 'N/A', :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save
                        else
                          puts "The record #{@the_line} already exists. No records were created."
                        end
                      end
                    end    
                  else
                    if line[2].match /^UZ.*\z/
                      if @record.nil?
                        @i = Item.create(:call_number => line[10], :name => get_name(line[10]),:location => line[8])
                        @i.created_at = Time.now.strftime('%B %Y')
                        @i.updated_at = Time.now
                        @i.save
                        co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                            :patron_status => get_status(line[3]), :patron_college => line[5], :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save 
                      else
                        @co = Checkout.find_by_transaction_id(line[0])
                        if @co.nil?
                          co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                        :patron_status => get_status(line[3]), :patron_college => line[5], :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save
                        else
                          puts "The record #{@the_line} already exists. No records were created."
                        end
                      end
                    else  
                      if @record.nil?  
                        @i = Item.create(:call_number => line[10], :name => get_name(line[10]),:location => line[8])
                        @i.created_at = Time.now.strftime('%B %Y')
                        @i.updated_at = Time.now
                        @i.save
                        co = @i.checkouts.create(:transaction_id => line[0], :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => get_status(line[2]), :patron_college => 'N/A', :renewals => 0)
                        co.created_at = Time.now.strftime('%B %Y')
                        co.updated_at = Time.now
                        co.save 
                      else
                        @co = Checkout.find_by_transaction_id(line[0])
                        if @co.nil?
                          co = Checkout.create(:transaction_id => line[0], :item_id => @record.id, :date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                      :patron_status => get_status(line[2]), :patron_college => 'N/A', :renewals => 0)
                          co.created_at = Time.now.strftime('%B %Y')
                          co.updated_at = Time.now
                          co.save
                        else
                          puts "The record #{@the_line} already exists. No records were created."
                        end
                      end
                    end
                  end    
                end
              end  
            end  
           else
             if line[3] == 'ILLOST-PAID'
               puts "This is not a circulation."
             else   
               puts "The record #{@the_line} has no corresponding checkout. No records were created."
               @errors << @the_line
             end   
           end
          elsif line[1].match /^S\d\dRY.*\z/ or line[1].match /^S\d\dRV.*\z/
            @record = Item.find_by_call_number(line[2])
            if @record.nil?
              puts "The record #{@the_line} has no corresponding checkout. No records were created."
              @errors << @the_line
            else
              open_record = @record.checkouts.find_all_by_end_time(nil).first
              if open_record.nil?
                record = @record.checkouts.last
                Checkout.update(record.id, :renewals => record.renewals + 1)
                puts "Renewals for #{record.id} were updated."
              else  
                Checkout.update(open_record.id, :renewals => open_record.renewals + 1)
                puts "Renewals for #{open_record.id} were updated."
              end  
            end 
          elsif line[1].match /^S\d\dEV.*\z/
            @record = Item.find_by_call_number(line[2])
            if @record.nil?
              puts "The record #{@the_line} has no corresponding checkout. No records were created."
            else
              if line[3] == 'ILLOST-PAID'
                 puts "This is not a circulation."
               else   
                 open_record = @record.checkouts.find_all_by_end_time(nil).first
                 if open_record.nil?
                   puts "The record #{@the_line} has no corresponding checkout. No records were created."
                   @errors << @the_line
                 else   
                   Checkout.update(open_record.id, :end_time => get_time(line[0]))
                   puts "The end time for #{open_record.id} was updated."
                 end
               end   
            end   
          end        
        rescue CSV::MalformedCSVError
          @errors << @the_line
          next
        end       
      end                   
  end
end