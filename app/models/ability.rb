class Ability
  include Spotlight::Ability

  # Restrict potentially destructive bulk updates to superadmin users
  # (i.e. users that are application-wide admins). Less destructive
  # bulk updates such as visibility, adding/removing tags are still
  # allowed for exhibit-specific admins and curators.
  def initialize(user)
    user ||= Spotlight::Engine.user_class.new
    super
    remove_bulk_update_permissions(user)
  end

  def remove_bulk_update_permissions(user)
    return if user.superadmin?
    cannot :bulk_update, Spotlight::Exhibit
  end
end