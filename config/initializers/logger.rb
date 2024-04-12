# Spammers were blowing up our logs. This suppresses common error classes
# that should be ignored.
if Rails.env.production?
  class ActionDispatch::DebugExceptions
    alias_method :old_log_error, :log_error
    def log_error(env, wrapper)
      if ignored_error_classes.include? wrapper.exception.class
        return
      else
        old_log_error env, wrapper
      end
    end

    # To ignore an error class in the logs, add it to this array and
    # restart Apache (sudo systemctl restart httpd)
    def ignored_error_classes
      [ActionController::RoutingError, Blacklight::Exceptions::RecordNotFound,
       ActiveRecord::RecordNotFound, Riiif::ConversionError, I18n::InvalidLocale,
       Blacklight::Exceptions::InvalidRequest, IIIF::Image::InvalidAttributeError]
    end
  end
end