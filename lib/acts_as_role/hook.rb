# encoding: utf-8

module ActsAsRole::Hook
  def acts_as_role(*args)
    options = args.extract_options!
    has_many :users
    has_and_belongs_to_many :permissions
    validates_presence_of :name
    validates_uniqueness_of :name

    include ActsAsRole::InstanceMethods
  end
end

