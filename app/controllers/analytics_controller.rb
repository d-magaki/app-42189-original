class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    # 社員別売上（ユーザー名と売上合計）
    @sales_by_employee = Project.joins(:user)
                                .group("users.user_name")
                                .sum(:revenue)

    # 依頼種別ごとの案件数
    @request_type_counts = Project.group(:request_type).count

    # 納期までの残り日数をもとにした案件数（例：0〜3日, 4〜7日など）
    @delivery_timelines = Project
      .where("due_date >= ?", Date.today)
      .group_by { |p| categorize_timeline(p.due_date) }
      .transform_values(&:count)
  end

  private

  def categorize_timeline(due_date)
    days_left = (due_date - Date.today).to_i
    case days_left
    when 0..3
      "0〜3日"
    when 4..7
      "4〜7日"
    when 8..14
      "8〜14日"
    else
      "15日以上"
    end
  end
end
