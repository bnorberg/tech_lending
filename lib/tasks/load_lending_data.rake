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
        name = n.split('#')[0]
        name
      end  
      
      def get_status(s)
        status = c.split('-')[1]
        status
      end  
      
      def get_time(t)
        time =  t[1..12]
        datetime = DateTime.parse(time).to_datetime.to_s
        just_time = Time.parse(datetime)
        just_time
      end  
      
      @filename = ENV["FILE_PATH"].split("/").last
      puts @filename
      @rejected_filenames = @filename.sub(".txt", "")
      load_errors_dir = File.join(Rails.root, "/tmp", "/load_errors" "/#{@rejected_filenames}_rejected_files.txt")
      @errors = File.new("#{load_errors_dir}", "w")
      file = File.new("#{ENV["FILE_PATH"]}", "r")
      file.each do |l|
        begin 
          the_line = l
          line = CSV.parse_line(the_line, {:col_sep => '^', :encoding => 'n'})
          if line[5] == 'UTCHECKEDOUT'
            @record = Item.find_by_call_number(line[8])
            puts @record.inspect
            if @record.nil?
              @i = Item.create(:call_number => line[8], :name => get_name(line[8]),:location => line[6]) 
              @i.created_at = Time.now.strftime('%B %Y')
              @i.updated_at = Time.now
              @i.save
              if line[5]=='UTCHECKEDOUT'
                if line[6]=='PEUNDERGRAD'
                  @i.checkouts.create(:date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => get_status(line[2]), :patron_college => line[4], :renewals => 0)
                  @i.created_at = Time.now.strftime('%B %Y')
                  @i.updated_at = Time.now
                  @i.save
                else
                  co = @i.checkouts.create(:date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => line[4].delete('PE'), :patron_college => line[3], :renewals => 0)
                  co.created_at = Time.now.strftime('%B %Y')
                  co.updated_at = Time.now
                  co.save         
                end
              end  
            else
              if line[6]=='UTCHECKEDOUT'
                if line[5]=='PEUNDERGRAD'
                  @i.checkouts.create(:date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => line[2].split('-')[1], :patron_college => line[4], :renewals => 0)
                  @i.created_at = Time.now.strftime('%B %Y')
                  @i.updated_at = Time.now
                  @i.save
                else
                  co = @i.checkouts.create(:date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                          :patron_status => line[4].delete('PE'), :patron_college => line[3], :renewals => 0)
                  co.created_at = Time.now.strftime('%B %Y')
                  co.updated_at = Time.now
                  co.save          
                end
              else
               @checkout = @record.checkouts.last.id
                puts @checkout
                if line[1].include? "EV"
                 Checkout.update(@checkout, :end_time => get_time(line[0]))
                else
                 resource = Checkout.find(@checkout)
                 Checkout.update(@checkout, :renewals => resource.renewals + 1)
                end    
              end
            end
          else  
            @record = Item.find_by_call_number(line[9])
            puts @record.inspect  
            if @record.nil?
                @i = Item.create(:call_number => line[9], :name => get_name(line[9]),:location => line[7])
                @i.created_at = Time.now.strftime('%B %Y')
                @i.updated_at = Time.now
                @i.save
                if line[6]=='UTCHECKEDOUT'
                    co = @i.checkouts.create(:date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                            :patron_status => line[5], :patron_college => 'N/A', :renewals => 0)
                    co.created_at = Time.now.strftime('%B %Y')
                    co.updated_at = Time.now
                    co.save    
                end  
            else
                if line[6]=='UTCHECKEDOUT'
                  co = @i.checkouts.create(:date => get_date(line[0]), :start_time => get_time(line[0]), :end_time => '', :duration => '',
                                            :patron_status => line[5], :patron_college => 'N/A', :renewals => 0)
                  co.created_at = Time.now.strftime('%B %Y')
                  co.updated_at = Time.now
                  co.save    
                else
                 @checkout = @record.checkouts.last.id
                  puts @checkout
                  if line[1].include? "EV"
                   Checkout.update(@checkout, :end_time => get_time(line[0]))
                  else
                   resource = Checkout.find_by_id(@checkout)
                   Checkout.update(@checkout, :renewals => resource.renewals + 1)
                  end    
                end
            end
          end   
        rescue CSV::MalformedCSVError
          @errors << the_line
          next
        end       
      end                   
  end
end  