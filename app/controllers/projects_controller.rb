class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  require 'roo'

  def index
    @projects = Project.includes(:user).all
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
      attach_files
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

    Rails.logger.debug "更新データ: #{params[:project].inspect}"

    if @project.update(project_params)
      redirect_to @project, notice: "案件を更新しました！"
    else
      Rails.logger.debug "更新失敗: #{@project.errors.full_messages}"
      render :edit
    end
  end

  def destroy
    @project = Project.find(params[:id])

    Rails.logger.debug "削除リクエスト受信: #{@project.inspect}"

    @project.attachments.purge if @project.attachments.attached?

    if @project.destroy
      Rails.logger.debug "削除成功: ID #{@project.id}"
      redirect_to projects_path, notice: "案件を削除しました！"
    else
      Rails.logger.debug "削除失敗: #{@project.errors.full_messages}"
      redirect_to projects_path, alert: "削除できませんでした！"
    end
  end

  # CSV/Excel インポート処理
  def import
    Rails.logger.debug "インポート処理開始: #{params.inspect}"

    file = params[:file]

    if file.blank?
      Rails.logger.debug "⚠️ファイルが選択されていません"
      redirect_to projects_path, alert: "ファイルを選択してください。" and return
    end

    Rails.logger.debug "受信したファイル: #{file.original_filename}"

    begin
      spreadsheet = Roo::Spreadsheet.open(file.path)
      Rails.logger.debug "✅シート名: #{spreadsheet.sheets.inspect}"
    rescue => e
      Rails.logger.error "⚠️Excelの読み込みに失敗: #{e.message}"
      redirect_to projects_path, alert: "ファイルの解析に失敗しました。" and return
    end

    header = spreadsheet.row(1)
    Rails.logger.debug "読み込んだヘッダー: #{header}"

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      Rails.logger.debug "処理中の行データ: #{row}"

      user = User.find_by(employee_id: row["社員ID"])
      status_value = { "未着手" => 0, "進行中" => 1, "完了" => 2 }[row["状態"]] || 0

      valid_request_types = ["新規依頼", "修正依頼", "追加依頼", "バグ修正", "その他＿依頼"]
      valid_request_contents = ["WEBアプリ制作", "WEBデザイン制作", "スマホアプリ制作", "システム構築", "データ解析", "その他＿内容"]

      request_type_value = row["依頼種別"]
      request_content_value = row["依頼内容"]

      unless valid_request_types.include?(request_type_value)
        Rails.logger.warn "⚠️ 無効な依頼種別: #{request_type_value} → `その他＿依頼` に変更"
        request_type_value = "その他＿依頼"
      end

      unless valid_request_contents.include?(request_content_value)
        Rails.logger.warn "⚠️ 無効な依頼内容: #{request_content_value} → `その他＿内容` に変更"
        request_content_value = "その他＿内容"
      end

      begin
        project = Project.create!(
          customer_name: row["顧客名"],
          sales_office: row["営業拠点"],
          sales_representative: row["営業担当"],
          request_type: request_type_value,
          request_content: request_content_value,
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

        Rails.logger.debug "✅ 登録成功: #{project.inspect}"
      rescue => e
        Rails.logger.error "⚠️ インポートエラー（行#{i}）: #{e.message}"
      end
    end

    redirect_to projects_path, notice: "案件データをインポートしました！"
  end

  # 分析アクション
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

  def attach_files
    if params[:project][:attachments].present?
      @project.attachments.attach(params[:project][:attachments])
    end
  end

  def project_params
    params.require(:project).permit(
      :customer_name, :sales_office, :sales_representative,
      :request_type, :request_content, :order_date, :due_date,
      :revenue, :cost, :profit, :remarks, :status, :user_id,
      :assigned_person, :planning_start_date, :planning_end_date,
      :design_start_date, :design_end_date, :development_start_date,
      :development_end_date, attachments: []
    )
  end
end
