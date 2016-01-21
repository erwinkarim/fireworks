class ApplicationController < ActionController::Base
	#before_filter :authenticate_ads_user!
	#before_filter :configure_permitted_parameters, if: :devise_controller?
	after_filter :store_location
	def store_location
		# store last url - this is needed for post-login redirect to whatever the user last visited.
		return unless request.get?
		if (request.path != "/ads_users/sign_in" &&
			request.path != "/ads_users/sign_up" &&
			request.path != "/ads_users/password/new" &&
			request.path != "/ads_users/password/edit" &&
			request.path != "/ads_users/confirmation" &&
			request.path != "/ads_users/sign_out" &&
			!request.xhr?) # don't store ajax calls
			session[:previous_url] = request.fullpath
		end
	end

	def after_sign_in_path_for(resource)
		session[:previous_url] || root_path
		#ads_user_watch_lists_path(current_ads_user.login)
	end

	protected
	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_in ) do |username|
		end
	end

  #rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
  #  render :text => exception, :status => 500
  #end

  helper :all
  protect_from_forgery
end
