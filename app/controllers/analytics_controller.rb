class AnalyticsController < ApplicationController
  def index
    # ▼ パラメータ取得とパース（不正な値は rescue）
    @form_params = {
      sales_from:   parse_date(params[:sales_from]),
      sales_to:     parse_date(params[:sales_to]),
      request_from: parse_date(params[:request_from]),
      request_to:   parse_date(params[:request_to]),
      status_from:  parse_date(params[:status_from]),
      status_to:    parse_date(params[:status_to]),
      average_from: parse_date(params[:average_from]),
      average_to:   parse_date(params[:average_to])
    }

    # ▼ デフォルト値補完
    today = Date.today
    @form_params[:sales_from]   ||= today.beginning_of_month
    @form_params[:sales_to]     ||= today.end_of_month
    @form_params[:request_from] ||= today.beginning_of_month
    @form_params[:request_to]   ||= today.end_of_month
    @form_params[:status_from]  ||= today.beginning_of_month
    @form_params[:status_to]    ||= today.end_of_month
    @form_params[:average_from] ||= today
    @form_params[:average_to]   ||= today + 1.month

    # ▼ カスタムグラフ用設定
    @selected_axis = params[:axis_field] || "user.user_name"
    @selected_metric = params[:metric] || "revenue"
    @selected_chart_type = params[:chart_type] || "bar"

    # ▼ カスタムグラフデータ集計
    projects = Project.where(created_at: @form_params[:sales_from].beginning_of_day..@form_params[:sales_to].end_of_day)

    if @selected_axis.blank? && @selected_chart_type == "line"
      # ▼ 折れ線グラフ + X軸なし → 日別推移
      raw_data = if @selected_metric == "count"
        projects.group("DATE(created_at)").count
      else
        projects.group("DATE(created_at)").sum(@selected_metric)
      end
      @custom_data = raw_data.sort.to_h
    elsif @selected_axis.blank?
      # ▼ X軸なし（棒グラフ・円グラフ）→ 全体集計
      total = @selected_metric == "count" ? projects.count : projects.sum(@selected_metric)
      @custom_data = { "全体" => total }
    else
      # ▼ X軸指定あり
      case @selected_axis
      when "planning_user.user_name"
        projects = projects.joins(:planning_user).group("users.user_name")
      when "design_user.user_name"
        projects = projects.joins(:design_user).group("users.user_name")
      when "development_user.user_name"
        projects = projects.joins(:development_user).group("users.user_name")
      when "user.user_name"
        projects = projects.joins(:user).group("users.user_name")
      when "sales_representative", "sales_office", "customer_name", "status"
        projects = projects.group(@selected_axis)
      else
        projects = projects.group(@selected_axis)
      end

      raw_data = @selected_metric == "count" ? projects.count : projects.sum(@selected_metric)
      @custom_data = raw_data.sort_by { |_, v| -v }.first(30).to_h
    end

    # nil対策（未設定）
    @custom_labels = @custom_data.keys.map { |k| k.presence || "未設定" }
    @custom_values = @custom_data.values

    # ▼ 依頼種別割合
    @request_type_counts = Project
      .where(created_at: @form_params[:request_from].beginning_of_day..@form_params[:request_to].end_of_day)
      .group(:request_type)
      .count

    # ▼ 案件ステータス一覧（未着手／進行中／完了を0件でも表示）
    expected_statuses = ["未着手", "進行中", "完了"]
    raw_status_counts = Project
      .where(created_at: @form_params[:status_from].beginning_of_day..@form_params[:status_to].end_of_day)
      .group(:status)
      .count
    @status_summary = expected_statuses.index_with { |s| raw_status_counts[s] || 0 }

    # ▼ 平均処理数（完了以外、納期ベース）
    incomplete = Project
      .where.not(status: "完了")
      .where(due_date: @form_params[:average_from]..@form_params[:average_to])
    @remaining_projects = incomplete.count
    @remaining_days = (@form_params[:average_to] - @form_params[:average_from]).to_i

    @average_per_day =
      if @remaining_days > 0
        (@remaining_projects.to_f / @remaining_days).round(1)
      else
        nil
      end
  end

  private

  def parse_date(str)
    Date.parse(str) rescue nil
  end
end
