class CheckoutsController < ApplicationController
  # GET /checkouts
  # GET /checkouts.json
  def index  
    require 'csv'
    @q = Checkout.search(params[:q])
    @checkouts = @q.result(:distinct => true).paginate(:page =>params[:page], :per_page => 25)
    respond_to do |format|
      format.html # index.html.erb  
      format.json { render :json => @checkouts }
      format.csv do
	      @checkouts = @q.result(:distinct => true)
       	csv_string = CSV.generate do |csv|
      	   #header
      	   csv << ["call number", "checkout date", "start time", "end time", "patron status", "patron college", "renewals"]
      	   @checkouts.each do |co|
            #data rows
        		 csv << [co.call_number, co.date, co.start_time, co.end_time, co.patron_status, co.patron_college, co.renewals]
           end
      	end
          #send to browser
  	        send_data csv_string, :type =>'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=checkouts.csv"
      end	
    end
  end

  # GET /checkouts/1
  # GET /checkouts/1.json
  def show
    @checkout = Checkout.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @checkout }
    end
  end

  # GET /checkouts/new
  # GET /checkouts/new.json
  def new
    @checkout = Checkout.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @checkout }
    end
  end

  # GET /checkouts/1/edit
  def edit
    @checkout = Checkout.find(params[:id])
  end

  # POST /checkouts
  # POST /checkouts.json
  def create
    @checkout = Checkout.new(params[:checkout])

    respond_to do |format|
      if @checkout.save
        format.html { redirect_to @checkout, notice: 'Checkout was successfully created.' }
        format.json { render json: @checkout, status: :created, location: @checkout }
      else
        format.html { render action: "new" }
        format.json { render json: @checkout.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /checkouts/1
  # PUT /checkouts/1.json
  def update
    @checkout = Checkout.find(params[:id])

    respond_to do |format|
      if @checkout.update_attributes(params[:checkout])
        format.html { redirect_to @checkout, notice: 'Checkout was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @checkout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checkouts/1
  # DELETE /checkouts/1.json
  def destroy
    @checkout = Checkout.find(params[:id])
    @checkout.destroy

    respond_to do |format|
      format.html { redirect_to checkouts_url }
      format.json { head :no_content }
    end
  end
end
