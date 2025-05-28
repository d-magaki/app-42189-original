class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :basic_auth, if: -> { Rails.env.production? }

  def after_sign_in_path_for(resource)
    home_path
  end

  private

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end
