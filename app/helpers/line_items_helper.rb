module LineItemsHelper

    # 重定向到存储的地址或者默认地址
    def redirect_back_or(default)
      redirect_to(session[:forwarding_url] || default)
      session.delete(:forwarding_url)
    end

    # 存储后面需要使用的地址
    def store_location
      # request.env['HTTP_REFERER']
      session[:forwarding_url] = request.referer # request.original_url if request.get?
    end

end
