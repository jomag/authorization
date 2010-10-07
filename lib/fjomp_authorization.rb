require File.dirname(__FILE__) + "/acts_as_user.rb"

ActiveRecord::Base.send :include, Jom::Authorization

