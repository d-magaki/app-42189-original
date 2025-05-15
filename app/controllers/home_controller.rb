class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    # ここに今後、ユーザー管理や案件管理へのリンクを置いていく予定
  end
end