class ApplicationController < ActionController::Base

# Primary Authors: Katie Siegel and Ari Vogel

	layout 'flatly'

  	# Prevent CSRF attacks by raising an exception.
  	# For APIs, you may want to use :null_session instead.
  	protect_from_forgery with: :exception
  	helper_method [:logged_in?, :current_user]
  	before_action :require_login

  	# Checks whether a user is logged in.
  	def logged_in?
  		!!current_user
  	end

  	private

  	# Makes sure that the user is logged in before they can view any other page than the login page.
  	def require_login
  		unless (current_user and session_active)
	  		flash[:error] = "You must be logged in to access this page"
	  		redirect_to root_url
  		end
  	end

  	def current_user
  	   @current_user ||= User.find(session[:user_id]) if (session[:user_id] and Session.find_by user_id: session[:user_id])
  	end

    def current_token
      session[:access_token]
    end

      #checks if a session exists in the database
      def session_active
        session_model = Session.find_by user_id: session[:user_id]
        if session_model == nil
          return false
        else
          session_model.active_check()
        end
      end
end
