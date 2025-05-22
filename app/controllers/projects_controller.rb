class ProjectsController < ApplicationController
  before_action :basic_auth
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  include ProjectsHelper
  require 'roo'

  def index
    using_custom_filter = current_user.admin? &&
      (params[:department].present? || params[:status].present? || params[:assignee_name].present?)

    @filter = using_custom_filter ? nil : (params[:filter].presence || "in_progress")
    @projects = Project.includes(:planning_user, :design_user, :development_user).all

    if current_user.admin?
      if params[:assignee_name].present?
        name = params[:assignee_name]
        @projects = @projects.select do |p|
          [p.planning_user, p.design_user, p.development_user].compact.any? { |u| u.user_name.include?(name) }
        end
      end

      if params[:status].present?
        @projects = @projects.select { |p| p.status == params[:status] }
      end

      if params[:department].present?
        dept = params[:department]
        @projects = @projects.select do |p|
          user = p.send("#{dept}_user")
          user.present? && user.department == dept
        end
      end
    else
      users_scope = User.where(department: current_user.department, role: :employee)

      @employee_tasks = users_scope.each_with_object({}) do |user, hash|
        next if user.user_name.to_s.strip.blank?

        count = @projects.count do |project|
          should_show_in_list_for_user?(project, user, "all", require_own: true) # ✅ require_own: true に変更
        end

        hash[user] = count if count > 0
      end

      # 一般社員：部署内で一致する案件を上部リストに表示
      @projects = @projects.select do |project|
        users_scope.any? do |user|
          user.user_name.to_s.strip.present? && should_show_in_list_for_user?(project, user, @filter)
        end
      end
    end
  end

  def show; end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user

    if @project.save
      redirect_to @project, notice: '案件を登録しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if params[:remove_attachments].present?
      params[:remove_attachments].each do |id|
        attachment = @project.attachments.find_by(id: id)
        attachment.purge if attachment.present?
      end
    end

    if params[:project][:attachments].present?
      @project.attachments.attach(params[:project][:attachments])
    end

    %i[planning_user_id design_user_id development_user_id].each do |key|
      params[:project][key] = nil if params[:project][key].blank?
    end

    if @project.update(project_params.except(:attachments, :employee_id))
      redirect_to @project, notice: "案件を更新しました！"
    else
      logger.debug "❌ 更新失敗: #{@project.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.attachments.purge if @project.attachments.attached?
    if @project.destroy
      redirect_to projects_path, notice: "案件を削除しました！"
    else
      redirect_to projects_path, alert: "削除できませんでした！"
    end
  end

  def destroy_selected
    if current_user.admin?
      if params[:project_ids].present?
        Project.where(id: params[:project_ids]).each do |project|
          project.attachments.purge if project.attachments.attached?
          project.destroy
        end
        redirect_to projects_path, notice: "選択した案件を削除しました。"
      else
        redirect_to projects_path, alert: "削除する案件を選択してください。"
      end
    else
      redirect_to projects_path, alert: "権限がありません。"
    end
  end

  def import
    file = params[:file]
    if file.blank?
      redirect_to projects_path, alert: "ファイルを選択してください。" and return
    end

    begin
      spreadsheet = Roo::Spreadsheet.open(file.path)
    rescue => e
      redirect_to projects_path, alert: "ファイルの解析に失敗しました。" and return
    end

    header = spreadsheet.row(2)
    (3..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      status_map = { "未着手" => 0, "進行中" => 1, "完了" => 2 }
      request_type_list = ["新規依頼", "修正依頼", "追加依頼", "バグ修正", "その他＿依頼"]
      request_content_list = ["WEBアプリ制作", "WEBデザイン制作", "スマホアプリ制作", "システム構築", "データ解析", "その他＿内容"]

      request_type = request_type_list.include?(row["依頼種別"]) ? row["依頼種別"] : "その他＿依頼"
      request_content = request_content_list.include?(row["依頼内容"]) ? row["依頼内容"] : "その他＿内容"
      status = status_map[row["状態"]] || 0

      project = Project.new(
        customer_name: row["顧客名"],
        sales_office: row["営業拠点"],
        sales_representative: row["営業担当"],
        request_type: request_type,
        request_content: request_content,
        order_date: row["受注日"],
        due_date: row["納期"],
        revenue: row["売上"].to_i,
        cost: row["コスト"].to_i,
        profit: row["利益"].to_i,
        remarks: row["備考"],
        status: status,
        user_id: current_user.id,
        planning_start_date: row["企画開始日"],
        planning_end_date: row["企画完了日"],
        design_start_date: row["設計開始日"],
        design_end_date: row["設計完了日"],
        development_start_date: row["開発開始日"],
        development_end_date: row["開発完了日"],
        planning_user_id: User.find_by(employee_id: row["企画ID"])&.id,
        design_user_id: User.find_by(employee_id: row["設計ID"])&.id,
        development_user_id: User.find_by(employee_id: row["開発ID"])&.id
      )

      if project.save
        Rails.logger.info "✅ インポート成功（行#{i}）: #{project.customer_name}"
      else
        Rails.logger.warn "⚠️ インポートエラー（行#{i}）: #{project.errors.full_messages.join(', ')}"
      end
    end

    redirect_to projects_path, notice: "案件データのインポート処理が完了しました。"
  end

  def analysis
    @count_by_status = Project.group(:status).count
    @count_by_month = if params[:from].present? && params[:to].present?
      from = Date.parse(params[:from]).beginning_of_day
      to = Date.parse(params[:to]).end_of_day
      Project.where(created_at: from..to).group_by_month(:created_at, format: "%Y-%m").count
    else
      Project.group_by_month(:created_at, format: "%Y-%m").count
    end
  end

  private

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    permitted = params.require(:project).permit(
      :customer_name, :sales_office, :sales_representative,
      :request_type, :request_content, :order_date, :due_date,
      :revenue, :cost, :profit, :remarks, :status,
      :employee_id,
      :assigned_person, :planning_start_date, :planning_end_date,
      :design_start_date, :design_end_date,
      :development_start_date, :development_end_date,
      :planning_user_id, :design_user_id, :development_user_id,
      attachments: []
    )

    %i[planning_user_id design_user_id development_user_id].each do |key|
      permitted[key] = nil if permitted[key].blank?
    end

    permitted
  end

  def department_key(department)
    case department
    when "planning" then "planning"
    when "design" then "design"
    when "development" then "development"
    else nil
    end
  end
end
