class ItemsController < ApplicationController
  # GET /items
  # GET /items.json
  def index
      require 'csv'
      respond_to do |format|
        format.html do # index.html.erb
           @q = Item.includes([:checkouts]).search(params[:q])
           @items = @q.result(:distinct => true).order('id DESC').paginate(:page =>params[:page], :per_page => 25)
        end   
        format.json { render :json => @letters }
        format.csv do
  	      @items = @q.result
         	csv_string = CSV.generate do |csv|
        	   #header
        	   csv << ["call number", "location", "checkout date", "start time", "end time", "patron status", "patron college", "renewals"]
        	   @items.each do |item|
        	     if !item.checkouts.empty?
        	       item.checkouts.each do |co|
                   #data rows
              		 csv << [item.call_number, item.location, co.date, co.start_time, co.end_time, co.patron_status, co.patron_college, co.renewals]
            	   end 
               end
             end
        	end
            #send to browser
    	      send_data csv_string, :type =>'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=letters.csv"
        end	
      end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to @item, notice: 'Item was successfully created.' }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_url }
      format.json { head :no_content }
    end
  end
end
