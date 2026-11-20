class Ability
  include Spotlight::Ability

  # Restrict potentially destructive bulk updates to superadmin users
  # (i.e. users that are application-wide admins). Less destructive
  # bulk updates such as visibility, adding/removing tags are still
  # allowed for exhibit-specific admins and curators.
  def initialize(user)
    user ||= Spotlight::Engine.user_class.new
    super
    add_read_page_permissions(user)
    remove_bulk_update_permissions(user)
  end

  private

  # Added so that can? :read, page returns the correct results
  def add_read_page_permissions(user)
    can :read, Spotlight::Page, exhibit_id: user.viewer_roles.pluck(:resource_id)
  end

  def remove_bulk_update_permissions(user)
    return if user.superadmin?
    cannot :bulk_update, Spotlight::Exhibit
  end
end