class AdsUsers::SessionsController < Devise::SessionsController
  protect_from_forgery :except => [:delete]
 before_filter :configure_sign_in_params

  # GET /resource/sign_in
  # def new
  #   super
  # end

	#creating a new session
	#POST /resource/sign_in
	def create
		# process the domain names and combine the user name for authentication
	#	params[:ads_user][:username] = params[:ads_user][:login] + "@" + params[:ads_user][:domain]
	#	params[:ads_user][:email] = params[:ads_user][:login] + "@petronas.com.my"

	#	logger.info "username = " + params[:ads_user][:email]

		#set the admin login as the user who is logging in...
	#	ENV['devise_ldap_admin'] = params[:ads_user][:username]
	#	ENV['devise_ldap_admin_password'] = params[:ads_user][:password]
		super
	end

  # DELETE /resource/sign_out
   def destroy
     super
   end

	def ads_user_params
		params.rqeuire(:ads_user).permit( :login, :password, :password_confirmation, :remember_me, :email, :username, :domain )
	end

  protected

  # You can put the params you want to permit in the empty array.
   def configure_sign_in_params
     devise_parameter_sanitizer.for(:sign_in).push(:username, :login, :domain)
   end

end
