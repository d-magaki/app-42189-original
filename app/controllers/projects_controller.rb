class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  require 'roo'

  def index
    @filter = params[:filter].presence || "in_progress"
    @projects = Project.includes(:planning_user, :design_user, :development_user).all

    # 各工程の担当者を合算した件数（部署関係なく）
    @user_project_counts = User.all.index_with do |user|
      Project.where(
        "planning_user_id = :id OR design_user_id = :id OR development_user_id = :id",
        id: user.id
      ).count
    end

    # 未着手の案件だけを担当者別にカウント
    @employee_tasks = User.includes(:projects).each_with_object({}) do |user, hash|
      count = Project.where(
        "(planning_user_id = :id AND planning_start_date IS NULL AND planning_end_date IS NULL) OR
        (design_user_id = :id AND design_start_date IS NULL AND design_end_date IS NULL) OR
        (development_user_id = :id AND development_start_date IS NULL AND development_end_date IS NULL)",
        id: user.id
      ).count
      hash[user] = count
    end
  end


  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to projects_path, notice: "案件を登録しました！"
    else
      render :new
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])

    if params[:remove_attachments].present?
      params[:remove_attachments].each do |id|
        attachment = @project.attachments.find_by(id: id)
        attachment.purge if attachment.present?
      end
    end

    if params[:project][:attachments].present?
      @project.attachments.attach(params[:project][:attachments])
    end

    @project.planning_user_id = params[:project][:planning_user_id].presence
    @project.design_user_id = params[:project][:design_user_id].presence
    @project.development_user_id = params[:project][:development_user_id].presence

    if @project.update(project_params.except(:attachments, :employee_id, :planning_user_id, :design_user_id, :development_user_id))
      redirect_to @project, notice: "案件を更新しました！"
    else
      logger.debug "❌ 更新失敗: #{@project.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.attachments.purge if @project.attachments.attached?

    if @project.destroy
      redirect_to projects_path, notice: "案件を削除しました！"
    else
      redirect_to projects_path, alert: "削除できませんでした！"
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

    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      user = User.find_by(employee_id: row["社員ID"])
      status_value = { "未着手" => 0, "進行中" => 1, "完了" => 2 }[row["状態"]] || 0

      valid_request_types = ["新規依頼", "修正依頼", "追加依頼", "バグ修正", "その他＿依頼"]
      valid_request_contents = ["WEBアプリ制作", "WEBデザイン制作", "スマホアプリ制作", "システム構築", "データ解析", "その他＿内容"]

      request_type = valid_request_types.include?(row["依頼種別"]) ? row["依頼種別"] : "その他＿依頼"
      request_content = valid_request_contents.include?(row["依頼内容"]) ? row["依頼内容"] : "その他＿内容"

      begin
        Project.create!(
          customer_name: row["顧客名"],
          sales_office: row["営業拠点"],
          sales_representative: row["営業担当"],
          request_type: request_type,
          request_content: request_content,
          order_date: row["受注日"].to_s,
          due_date: row["納期"].to_s,
          revenue: row["売上"].to_i,
          cost: row["コスト"].to_i,
          profit: row["利益"].to_i,
          remarks: row["備考"],
          user_id: user&.id,
          assigned_person: row["担当社員名"],
          planning_start_date: row["企画開始日"].to_s,
          planning_end_date: row["企画完了日"].to_s,
          design_start_date: row["設計開始日"].to_s,
          design_end_date: row["設計完了日"].to_s,
          development_start_date: row["開発開始日"].to_s,
          development_end_date: row["開発完了日"].to_s,
          status: status_value
        )
      rescue => e
        Rails.logger.error "⚠️ インポートエラー（行#{i}）: #{e.message}"
      end
    end

    redirect_to projects_path, notice: "案件データをインポートしました！"
  end

  def analysis
    @count_by_status = Project.group(:status).count

    @count_by_month =
      if params[:from].present? && params[:to].present?
        from = Date.parse(params[:from]).beginning_of_day
        to   = Date.parse(params[:to]).end_of_day
        Project.where(created_at: from..to)
               .group_by_month(:created_at, format: "%Y-%m")
               .count
      else
        Project.group_by_month(:created_at, format: "%Y-%m").count
      end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
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
  end

  def dept_column(dept)
    case dept
    when "企画部" then "planning"
    when "情報設計部" then "design"
    when "開発部" then "development"
    else "unknown"
    end
  end
end
