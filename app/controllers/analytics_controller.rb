class AnalyticsController < ApplicationController
  def index
    # 社員名ごとの売上集計
    @sales_by_employee = Project.joins(:user)
                                .group("users.user_name")
                                .sum(:revenue)

    # 依頼種別の件数
    @request_type_counts = Project.group(:request_type).count

    # 納期ごとの件数（日付フォーマット込み）
    @delivery_timelines = Project
      .where(due_date: 1.month.ago..1.month.from_now)
      .group_by_day(:due_date, format: "%Y/%m/%d")
      .count
  end
end
