# encoding: utf-8

require 'rails'

module ActsAsRole
  class Railtie < Rails::Railtie
    config.to_prepare do
      ActiveRecord::Base.send(:extend, ActsAsRole::Hook)
    end
  end
end

