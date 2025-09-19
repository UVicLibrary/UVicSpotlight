# Fix NameError (undefined local variable or method `action' for an instance of BookmarksController)
Rails.application.config.to_prepare do
  BookmarksController.class_eval do
    def verify_user
      unless current_or_guest_user || (action_name == "index" && token_or_current_or_guest_user)
        flash[:notice] = I18n.t('blacklight.bookmarks.need_login')
        raise Blacklight::Exceptions::AccessDenied
      end
    end
  end
end