# Primary Author: Katie Siegel

class StaticPagesController < ApplicationController
	skip_before_action :require_login, only: :index

	#make sure the user is logged in
	def index
		if logged_in? then redirect_to receipts_url end
	end
end
