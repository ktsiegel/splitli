# Primary Authors: Ari Vogel and Katie Siegel

class PurchasesController < ApplicationController
	before_filter :set_receipt, only: :create
	before_filter :set_purchase, only: :destroy

	# POST
	# Uses ajax to create purchases, if a purchase is not created successfully, the javascript handles the error by displaying an error message.
	# Creates a new Purchase based on the params given in the request.
	def create	
		@purchase = Purchase.new(owner_phone_number: params[:owner_phone_number], receipt_id: @receipt.id.to_i, owner_name: params[:owner_name].to_s)
		@purchase_type = params[:purchase_type]
		if @purchase.save
			respond_to do |format|
				format.js{}
			end
		end
	end

	def update
	end

	# used with ajax to delete purchases from a receipt in the view
	def destroy
		if Purchase.destroy(@purchase.id)
			respond_to do |format|
				format.js{}
			end
		end
	end

	private

	# Before some methods are called, find the appropriate purchase on which the actions will be performed.
	def set_purchase
		@purchase = Purchase.find(params[:id])
	end

	# Before some methods are called, find the appropriate receipt on which the actions will be performed.
	def set_receipt
		@receipt = Receipt.find(params[:receipt_id])
	end
end
