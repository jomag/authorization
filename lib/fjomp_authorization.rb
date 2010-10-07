require 'acts_as_user.rb'

ActiveRecord::Base.send :include, Fjomp::Authorization

