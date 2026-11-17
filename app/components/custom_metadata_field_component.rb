# frozen_string_literal: true

# EXTEND blacklight v.8.3.0:
# This exists so we can sanitize links rendered in custom_metadata_field_component.html.erb.
# #sanitize must be called in the view, since it doesn't seem to work when called on
# the view context in the component itself.
class CustomMetadataFieldComponent < Blacklight::MetadataFieldComponent
end