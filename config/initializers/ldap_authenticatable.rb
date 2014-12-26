require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
	module Strategies
		class LdapAuthenticatable < Authenticatable
			def authenticate!
				if params[:ads_user]
					ldap = Net::LDAP.new
					ldap.host = ENV['devise_ldap_host']
					ldap.port = 636
					ldap.base = ENV['devise_ldap_base']
					ldap.encryption :simple_tls
					ldap.auth "PETRONAS\\#{login}", password
						
					if ldap.bind
						Rails.logger.info "login successful"
		
						#find the user
						filter = Net::LDAP::Filter.eq( 'samaccountname', params[:ads_user][:username] )
						search_result = ldap.search( :base => ENV['devise_ldap_base'], :filter => filter).first

						#check if the user is in the proper group
						if ENV['devise_check_group'] then
						else
							in_group = true
						end	

						#ads_user = AdsUser.find_or_create_by(login:params[:ads_user][:username])
						ads_user = AdsUser.where(:login => params[:ads_user][:username]).first

						if ads_user.nil? then
							ads_user = AdsUser.new(:login => params[:ads_user][:username], 
								:email => search_result[:mail].first, 
								:name => search_result[:displayname].first, 
								:username => search_result[:samaccountname].first, 
								:password => params[:ads_user][:password], :domain => params[:ads_user][:domain] )
							ads_user.save!
							Rails.logger.info "ads_user is #{ads_user.inspect}"
							params[:ads_user][:email] = search_result[:mail].first
						else
							ads_user.update_attributes({ :email => search_result[:mail].first, 
								:name => search_result[:displayname].first, 
								:password => params[:ads_user][:password], :domain => params[:ads_user][:domain] } )
						end

						success!(ads_user)
					else
						Rails.logger.info "login fail as #{login}"
						fail(:invalid_login)
					end
				end
			end

			#def email
			#	params[:ads_user][:username] + "@petronas.com.my"
			#end

			def login
				params[:ads_user][:username]
			end

			def password
				params[:ads_user][:password]
			end

			def login
				params[:ads_user][:username]
			end

			def user_data 
				login:login
			end
		end
	end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
