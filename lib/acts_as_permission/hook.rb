# encoding: utf-8

require "digest/md5"
require "digest/sha1"
   
module ActsAsPermission::Hook
  def acts_as_permission(*args)
    options = args.extract_options!
        
    has_and_belongs_to_many :roles
    validates_presence_of :name
    validates_uniqueness_of :name
    
    include ActsAsPermission::InstanceMethods
  end
end

