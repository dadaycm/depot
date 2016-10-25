class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :getTimeNow

  def getTimeNow
    @date_loaded = Time.now
    @string_now  = 'Now:'+Time.now.strftime("%Y-%m-%d %H:%M:%S")
  end
end
