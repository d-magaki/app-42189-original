class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # ログイン後の遷移先
  def after_sign_in_path_for(resource)
    home_path
  end
end
