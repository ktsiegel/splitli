require 'nokogiri'
require 'open-uri'

# Primary Author: Katie Siegel

class ReceiptsController < ApplicationController
	helper_method :current_user
	before_filter :set_receipt, only: [:edit, :update, :destroy]

	# GET
	# Lists all of the receipts in descending order of the date at which they were created.
	def index
		@receipt = Receipt.new
		@receipts = Receipt.where(user: current_user).order('created_at DESC')
	end

	# POST
	# Create a new receipt based on the parameters passed in the request. 
	# If the user has switched between itemized view and split evenly view, then the old receipt is trashed and a new one is created.
	def create
		if params[:old_receipt_id] #parameter that details whether there is an old receipt that should be trashed.
			Receipt.destroy(params[:old_receipt_id])
		end
		@receipt = Receipt.new(title: params[:receipt][:title], user_id: current_user.id, split_type: params[:split_type], been_sent: false)
		if @receipt.save
		  	# success
		  	redirect_to edit_receipt_url(@receipt)
		else
		  	# error handling
		  	flash[:alert] = "I'm sorry, there was an error in creating your receipt. Please make sure you are assigning a title to your new receipt."
		  	redirect_to receipts_url
		end
	end

	#A receipt is first created just by name, then edited until it contains all necessary information.
	def edit 
		@purchases = @receipt.purchases
		#receipts must have a purchase, this ensures that rep invariant
		@purchase = Purchase.new
		if @receipt.been_sent
			flash[:alert] = "The charges in this receipt have already been sent."
		end
	end

	#Update is used to finalize the receipt, calculates the charge for each person, then sends out charges 
	def update
		if @receipt.update(receipt_params)
			amnt = params[:receipt][:total_amount] #the amount that is used to update the receipt
			tip = params[:receipt][:tip] #the tip submitted by the user
			puts 'asdfasdf' + amnt.to_f.nan?.to_s
			#checks that an amount exists for evenly split receipts
			if ((!amnt or amnt == "" or amnt.to_f<=0.0 or (tip and tip.to_f<0.0)) and @receipt.split_type == "Split Evenly") 
				flash[:alert] =  "Please double check that you have submitted a valid non-zero amount."
				redirect_to edit_receipt_url(@receipt)
			#checks that a receipt has purchases
			elsif @receipt.purchases.length == 0
				flash[:alert] = "Please enter people you are splitting the bill with"
				redirect_to edit_receipt_url(@receipt)
			else
				#sends out all charges using methods in the model
				amnt = @receipt.conduct_payment_process(params[:tax], current_token)
				# calculate the total amount if the receipt was created as an itemized receipt
				if @receipt.split_type == 'Itemize' then @receipt.update(total_amount: amnt) end
				@receipt.update(been_sent: true)
				flash[:notice] = "Payment successfully sent!"
				redirect_to receipts_url
			end
		else
			#handles errors in updating the receipt
			flash[:alert] = "Invalid input: please try again."
			redirect_to edit_receipt_url(@receipt)
		end
	end

	def destroy
		@receipt.destroy
		redirect_to receipts_url
	end

	private

	# make sure the appropriate params are present before the create method is called.
	def create_receipt_params
		params.require(:receipt).permit(:title)
	end

	# Use callbacks to share common setup or constraints between actions.
	def set_receipt
		@receipt = Receipt.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def receipt_params
		params.require(:receipt).permit(:total_amount, :tip)
	end
end
