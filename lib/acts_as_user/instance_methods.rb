# encoding: utf-8

module ActsAsUser::InstanceMethods
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

  def respond_to?(method_id, *args)
    m = method_id.to_s
    return true if matches_dynamic_role_check?(m)
    return true if matches_dynamic_permission_check?(m)
    super(method_id, *args)
  end

  def method_missing(method_id, *args)
    # FIXME: Use define_method for each is_xyz? or can_xyz? method.
    #        Methods should be defined on first use. This will be
    #        more efficient than the current solution
    
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

      self.permissions.each do |perm|
        if m.captures.first == perm.name
          return true
        end
      end
      
      return false

      # Old implementation. This method caused another SQL-query
      # even if the user had been eager loaded
      #
      #if self.permissions.find_by_name(m.captures.first)
      #  return true
      #else
      #  return false
      #end
    end

    super(method_id)
  end
end

