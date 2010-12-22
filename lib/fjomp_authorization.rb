# encoding: utf-8

require 'active_support/core_ext'

require File.join(File.dirname(__FILE__), 'acts_as_permission/railtie.rb')
require File.join(File.dirname(__FILE__), 'acts_as_role/railtie.rb')
require File.join(File.dirname(__FILE__), 'acts_as_user/railtie.rb')

module ActsAsPermission
  autoload :Hook, File.join(File.dirname(__FILE__), 'acts_as_permission/hook.rb')
  autoload :InstanceMethods, File.join(File.dirname(__FILE__), 'acts_as_permission/instance_methods.rb')
end

module ActsAsRole
  autoload :Hook, File.join(File.dirname(__FILE__), 'acts_as_role/hook.rb')
  autoload :InstanceMethods, File.join(File.dirname(__FILE__), 'acts_as_role/instance_methods.rb')
end

module ActsAsUser
  autoload :Hook, File.join(File.dirname(__FILE__), 'acts_as_user/hook.rb')
  autoload :InstanceMethods, File.join(File.dirname(__FILE__), 'acts_as_user/instance_methods.rb')
end

