class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_only, except: [:edit, :update]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: 'ユーザーを登録しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to users_path, notice: 'ユーザーを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, notice: 'ユーザーを削除しました。'
  end

  private

  def user_params
    params.require(:user).permit(:employee_id, :email, :password, :password_confirmation, :user_name, :department, :role)
  end

  def admin_only
    redirect_to root_path, alert: '権限がありません' unless current_user&.管理者?
  end
end
