class ApplicationController < ActionController::Base
  def index
    render plain: "Hello, world! Puma running on #{Socket.gethostname} with PID #{Process.pid} and Ruby #{RUBY_VERSION} as #{ENV['USER']}"
  end
end
