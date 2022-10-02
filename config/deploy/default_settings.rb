## This stage will use the default settings of the gems

### Service units will be lingered with the current user
# sidekiq service will be named : sample_app_puma_default_settings.service
# puma service will be named : sample_app_sidekiq_default_settings.service
# and located in /home/ubuntu/.config/systemd/user/
# the service will be type notify if the ruby engine is not jruby
