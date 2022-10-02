## This will force the puma service to have notify type
# but normally you should not need to do this if you remove the sd_notify gem from the Gemfile

set :puma_service_unit_type, :simple