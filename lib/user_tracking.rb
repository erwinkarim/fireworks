module UserTracking
	def self.link_user_to_ad ad_username, ad_password
		#create ldap connection
		ldap = Net::LDAP.new
		ldap.host = ENV['DEVISE_LDAP_HOST']
		ldap.port = 636
		ldap.base = ENV['DEVISE_LDAP_BASE']
		ldap.encryption :simple_tls
		ldap.authenticate ad_username, ad_password

		if ldap.bind then
			#get a list of users
			User.where(:ads_user_id => nil).each do |user|
			#User.all.each do |user|
				#check for ad connection. if got, check existing or create a new one, otherwise, it's 0
				filter = Net::LDAP::Filter.eq('samaccountname', user.name)
				results = ldap.search(:base => ldap.base, :filter => filter)
				if results.count != 0 then
					result = results.first
					#check if the user in Ads
					ads_user = AdsUser.find_by_login result[:samaccountname].first
					if ads_user.nil? then
						# AdsUser entry doesn't exist but he's a valid user
						# 	so, let's create a AdsUser entry
						random_password = SecureRandom::hex
						ads_user = AdsUser.new( :login => result[:samaccountname].first,
							:password => random_password, :password_confirmation => random_password,
							:email => result[:mail].first, :name => result[:displayname].first,
							:username => result[:userprincipalname].first,
							:title => result[:title].first,
							:domain => result[:userprincipalname].first.split('@').last )
						if ads_user.valid? then
							ads_user.save!
							#user is a valid ads user
							#check for department
							department = AdsDepartment.find_by_name(result[:department].first)
							if department.nil? then
								department = AdsDepartment.new(:name => result[:department].first, :company_name => result[:company].first)
								department.save!
							end
							ads_user.update_attribute(:ads_department_id, department.id)
						else
							#user.update_attribute(:ads_user_id, 0)
							puts "AdsUserCreation Failed"
						end
					else
						#reassign if the guy already exists
						if user.ads_user_id != ads_user.id then
							user.update_attribute(:ads_user_id, ads_user.id)
						end

						puts "checking title for #{ads_user.name}"
						#update the title if different
						if result[:title].first != ads_user.title then
							ads_user.update_attribute(:title, result[:title].first)
						end

						# AdsUser already exists, update department info
						department = AdsDepartment.find_by_name(result[:department].first)
						if department.nil? then
							department = AdsDepartment.new(:name => result[:department].first, :company_name => result[:company].first)
							department.save!
							ads_user.update_attribute(:ads_department_id, department.id)
						else
							#user moved department
							if department.id != ads_user.ads_department_id then
								ads_user.update_attribute(:ads_department_id, department.id)
							end

							#update company name
							department.update_attribute(:company_name, result[:company].first)
						end
					end
				end #if result !=0
			end


		else
			return -1
		end

	end

	def self.update_user_info ad_username, ad_password
		ldap = Net::LDAP.new
		ldap.host = ENV['DEVISE_LDAP_HOST']
		ldap.port = 636
		ldap.base = ENV['DEVISE_LDAP_BASE']
		ldap.encryption :simple_tls
		ldap.authenticate ad_username, ad_password

		if ldap.bind then
			User.where.not(:ads_user_id => nil).each do |user|
				filter = Net::LDAP::Filter.eq('samaccountname', user.name)
				result = ldap.search(:base => ldap.base, :filter => filter).first

				if !result.nil? then
					#update the user info
					ads_user = AdsUser.find_by_login result[:samaccountname].first
					ads_user.update_attributes({
						:name => result[:displayname].first,
						:title => result[:title].first
					})
					#check if they swich department
				end
			end
		end
	end
end
