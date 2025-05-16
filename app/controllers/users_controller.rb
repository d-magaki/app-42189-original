class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create, :find_by_employee_id]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      logger.debug "ユーザー登録成功"
      redirect_to users_path, notice: "ユーザーを登録しました。"
    else
      logger.debug "登録失敗: #{@user.errors.full_messages}"
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
      redirect_to users_path, notice: "ユーザー情報を更新しました。"
    else
      logger.debug "更新失敗: #{@user.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, notice: "ユーザーを削除しました。"
  end

  def find_by_employee_id
    user = User.find_by(employee_id: params[:employee_id])
    if user
      render json: {
        id: user.id,
        user_name: user.user_name,
        department: user.department,
        email: user.email,
        role: user.role
      }
    else
      render json: { error: "not_found" }, status: 404
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :employee_id, :user_name, :department,
      :role, :email, :password, :password_confirmation
    )
  end

  def admin_only
    redirect_to root_path, alert: "アクセス権限がありません" unless current_user&.role == "管理者"
  end
end
