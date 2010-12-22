# encoding: utf-8

require 'rails'

module ActsAsPermission
  class Railtie < Rails::Railtie
    config.to_prepare do
      ActiveRecord::Base.send(:extend, ActsAsPermission::Hook)
    end
  end
end

