class ItemsController < ApplicationController
	before_filter :set_purchase, only: :create
	before_filter :set_item, only: :destroy

	# POST
	# Creates a new item given an amount and a title
	# The title should be in params[:title] and the amount should be in params[:amount]
	def create
		if params[:amount] =~ /\d+\.*\d{0,2}/ and params[:amount].to_i > 0.0
			@item = Item.new(purchase_id: @purchase.id, title: params[:title], amount: params[:amount])
			if @item.save
				respond_to do |format|
					format.js{}
				end
			end
		end
	end

	# DELETE
	# Destroys a given item and calls the javascript that dynamically updates the view.
	def destroy
		if Item.destroy(@item.id)
			respond_to do |format|
				format.js{}
			end
		end
	end

	private

	# Before some methods are called, find the appropriate item on which the actions will be performed.
	def set_item
		@item = Item.find(params[:id])
	end

	# Before some methods are called, find the appropriate purchase on which the actions will be performed.
	def set_purchase
		@purchase = Purchase.find(params[:purchase_id])
	end
end