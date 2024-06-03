require 'rack'
require 'webrick'

LOGGING_BLACKLIST = ['/']

class FilteredCommonLogger < Rack::CommonLogger
  def call(env)
    if filter_log(env)
      # default CommonLogger behaviour: log and move on
      super
    else
      # pass request to next component without logging
      @app.call(env)
    end
  end

  # return true if request should be logged
  def filter_log(env)
    !LOGGING_BLACKLIST.include?(env['PATH_INFO'])
  end
end

if production?
  disable :logging
  use FilteredCommonLogger

  set :server_settings, AccessLog: []
end
