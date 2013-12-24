# Primary Author: Katie Siegel

class SessionsController < ApplicationController
	skip_before_action :require_login, only: :create

	#create a session containing the user_id and access token.  Also, a session model
	#is created and saved in the database for session timeouts.
	def create
	 	auth = request.env["omniauth.auth"]
	 	user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
	 	session[:user_id] = user.id
	  	session[:access_token] = auth["credentials"]["token"]
	  	@session = Session.new(user_id: user.id)
	  	@session.save()
	  	redirect_to receipts_url, :notice => "Signed in!"
	end

	#destroy the session, and delete the correct element from the database.  
	def destroy
		s = Session.find_by user_id: session[:user_id]
		if s != nil then s.destroy() end
	 	session[:user_id] = nil
	 	session[:access_token] = nil
	 	flash.keep(:error)
	 	redirect_to root_url, :notice => "Signed out!"
	end
end
