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
					#ldap.auth "#{login}@#{params[:ads_user][:domain]}", password
					ldap.auth "#{params[:ads_user][:username] }@#{params[:ads_user][:domain]}", password

					valid_login = false
					in_group = false
						
					if ldap.bind
						valid_login = true
		
						#find the user
						filter = Net::LDAP::Filter.eq( 'samaccountname', params[:ads_user][:username] )
						search_result = ldap.search( :base => ENV['devise_ldap_base'], :filter => filter).first

						#check if the user is in the proper group
						if ENV['devise_check_group'] == 'true' then
							group_search_results = ldap.search( :base => search_result[:dn].first, 
								:filter => Net::LDAP::Filter.ex( "memberof:1.2.840.113556.1.4.1941", ENV['devise_req_groups']),
								:scope => Net::LDAP::SearchScope_BaseObject)
							if group_search_results.length == 1 then
								in_group = true
							end
						else
							in_group = true
						end	
					end

					if valid_login && in_group then
						Rails.logger.info 'login is valid and login is in group'
						#start looking for user or create a new one
						ads_user = AdsUser.where(:login => params[:ads_user][:username]).first

						if ads_user.nil? then
							ads_user = AdsUser.new(:login => params[:ads_user][:username], 
								:email => search_result[:mail].first, 
								:name => search_result[:displayname].first, 
								:username => search_result[:samaccountname].first, 
								:password => params[:ads_user][:password], :domain => params[:ads_user][:domain] )
							ads_user.save!
							params[:ads_user][:email] = search_result[:mail].first
						else
							ads_user.update_attributes({ :email => search_result[:mail].first, 
								:name => search_result[:displayname].first, 
								:password => params[:ads_user][:password], :domain => params[:ads_user][:domain] } )
						end

						success!(ads_user)
					else
						Rails.logger.info 'Login failed!'
						#somehow this doesn't work if the user have logon before so blank out username field
						params[:ads_user][:username] = ""
						return fail(:invalid)
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
