class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

# protected
# 	def request_http_token_authentication(realm = "Application")
#   	self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
#   	render :json => {:error => "HTTP Token: Access denied."}, :status => :unauthorized
# 	end
end
