# require 'acts_as_user'

ActiveRecord::Base.send :include, Fjomp::Authorization

