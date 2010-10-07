# encoding: utf-8

#require "digest/md5"
#require "digest/sha1"
#require "rails"
   
module Fjomp
  module Authorization
    # Called automatically when this module is loaded
    def self.included(base)
      base.send :extend, UserClassMethods
      base.send :extend, RoleClassMethods
      base.send :extend, PermissionClassMethods
    end

    module RoleClassMethods
      def acts_as_role
        has_many :users
        has_and_belongs_to_many :permissions
        validates_presence_of :name
        validates_uniqueness_of :name
      end
    end

    module PermissionClassMethods
      def acts_as_permission
        has_and_belongs_to_many :roles
        validates_presence_of :name
        validates_uniqueness_of :name
      end
    end

    module UserClassMethods
      def acts_as_user(*args)
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

        send :include, InstanceMethods
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

    module InstanceMethods
      def generate_password_hash
        unless self.password.blank? or self.password_confirmation.blank?
          self.hashed_password = Digest::SHA1.hexdigest(self.password)
        end
      end

      def forget_plain_text_password
        # Forget plain text password as early as possible
        self.password = nil
        self.password_confirmation = nil
      end
      
      # Check if method_id matches a string like "is_admin_or_editor"
      def matches_dynamic_role_check?(method_id)
        /^is_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
      end

      # Check if method_id matches a string like "can_view_page"
      def matches_dynamic_permission_check?(method_id)
        /^can_([_a-zA-Z]\w*)\?$/.match(method_id.to_s)
      end

      # Split a string like "admin_or_editor" to "admin" + "editor"
      def tokenize_roles(str)
        str.split(/_or_/)
      end

      def method_missing(method_id, *args)
        # Match with role detection methods:
        #   user.is_admin?
        #   user.is_editor_or_admin?
        #   etc..
        if m = matches_dynamic_role_check?(method_id)
          if role
            tokenize_roles(m.captures.first).each do |check|
              return true if role.name.downcase == check
            end
          end

          return false
        end

        # Match with permission methods:
        #   user.can_view_page?
        #   user.can_edit_page?
        if m = matches_dynamic_permission_check?(method_id)
          return false if permissions.nil?

          if permissions.find_by_name(m.captures.first)
            return true
          else
            return false
          end
        end

        # No match
        super
      end
    end
  end
end

