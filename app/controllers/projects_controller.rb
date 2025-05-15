class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:edit, :update, :destroy]

  def index
    @projects = Project.order(created_at: :desc)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    @project.profit = @project.revenue.to_i - @project.cost.to_i

    if @project.save
      redirect_to projects_path, notice: "案件を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @project.assign_attributes(project_params)
    @project.profit = @project.revenue.to_i - @project.cost.to_i

    if @project.save
      redirect_to projects_path, notice: "案件を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "案件を削除しました。"
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :customer_name, :sales_office, :sales_representative,
      :request_type, :request_content, :order_date, :due_date,
      :revenue, :cost, :remarks, :attachments,
      :planning_start_date, :planning_end_date,
      :design_start_date, :design_end_date,
      :development_start_date, :development_end_date,
      :planning_user_id, :design_user_id, :development_user_id,
      :assigned_person, :status
    )
  end
end
