# encoding: utf-8

require 'rails'

module ActsAsUser
  class Railtie < Rails::Railtie
    config.to_prepare do
      ActiveRecord::Base.send(:extend, ActsAsUser::Hook)
    end
  end
end

