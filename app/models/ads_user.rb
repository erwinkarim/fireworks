class AdsUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :ldap_authenticatable, :registerable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :login, :password, :password_confirmation, :remember_me, :email
  #attr_accessible :username, :domain
	has_many :watch_lists

	validates :username, presence: true, uniqueness: true

  #before_validation :populate_fields

	def populate_fields
		Rails.logger.info "AdsUser self is #{self.inspect} "
		#need to login first before searching
		#ldap = Devise::LDAP::Adapter.ldap_connect(self.username)
		#ldap.ldap.authenticate self.username,self.password
		#if (ldap.ldap.bind) then
		#	results = ldap.ldap.search(:base => ldap.ldap.base, 
		#		:filter => Net::LDAP::Filter.eq('userprincipalname', self.username) )
		#	self.name = results.first[:displayname].first
		#	self.email = results.first[:mail].first
		#		self.login = self.email.split('@').first
		#	self.domain = self.username.split('@').last
		self.username =  self.login
		#end
	end

  def get_ldap_email
    self.email = Devise::LDAP::Adapter.get_ldap_param(self.username,"mail").first
    #self.email = self.username.split("\\").last
  end

  # use ldap uid as primary key
  #before_validation :get_ldap_id
  def get_ldap_id
		self.id = Devise::LDAP::Adapter.get_ldap_param(self.username,"uidnumber").first
  end
  #
  # hack for remember_token
  def authenticatable_token
		Digest::SHA1.hexdigest(email)[0,29]
  end
end
