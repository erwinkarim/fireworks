class AdsUsers::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

	#POST /resource/sign_in
	def create
		# process the domain names and combine the user name for authentication
		params[:ads_user][:username] = params[:ads_user][:login] + "@" + params[:ads_user][:domain]
		super
	end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
