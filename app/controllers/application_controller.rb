class ApplicationController < ActionController::Base
	#before_filter :authenticate_ads_user!
	#before_filter :configure_permitted_parameters, if: :devise_controller?

	protected
	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_in ) do |username|
		end 
	end

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  helper :all
  protect_from_forgery
end
