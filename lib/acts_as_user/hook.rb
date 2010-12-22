# encoding: utf-8

module ActsAsUser::Hook
  def acts_as_user(*args)
    options = args.extract_options!

    # Each user has a single role
    belongs_to :role
  
    # Access permissions of the users role directly
    delegate :permissions, :to => :role
  
    # Create getter and setter for passwrd
    attr_accessor :password
  
    # White-list for mass-assignment
    attr_accessible :username, :password, :password_confirmation
    attr_accessible :role_id
      
    before_create :generate_password_hash
    before_update :generate_password_hash
    after_create  :forget_plain_text_password
    after_save    :forget_plain_text_password

    # Validations
    validates_presence_of :role
    validates_presence_of :username, :message => 'User name can not be blank'
    validates_uniqueness_of :username, :message => 'This user name is not available'
    validates_presence_of :password, :on => :create, :message => 'Password must not be blank'
    validates_confirmation_of :password, :message => 'Passwords differs'
    validates_length_of :password, :within => 5..100, :on => :create,
                        :message => 'The password must be at least 5 characters long'
    validates_length_of :username, :minimum => 3,
                        :message => 'The user name must be at least 3 characters long'

    include ActsAsUser::InstanceMethods
  end
    
  # Find account by username. If the password is a match
  # the user is returned, if not nil is returned.
  def authenticate(username, password)
    a = self.find_by_username username
    return if a.nil?

    if defined? ldap_auth
      if a.ldap_auth then
        dn = ''
        ldap = Net::LDAP::new(:host => 'localhost', :base => 'dc=cmteknik,dc=se')
        filter = Net::LDAP::Filter.eq('uid', username)
        ldap.search(:filter => filter) { |entry| dn = entry.dn }
        ldap.auth(dn, password)
        if ldap.bind then
          return a
        else
          return nil
        end
      end
    end
          
    hash = Digest::SHA1.hexdigest(password || "")

    if hash == a.hashed_password then
      return a
    else
      return nil
    end
  end
end

