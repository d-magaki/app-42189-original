class Project < ApplicationRecord

  belongs_to :user
  belongs_to :planning_user, class_name: "User", foreign_key: "planning_user_id", optional: true
  belongs_to :design_user, class_name: "User", foreign_key: "design_user_id", optional: true
  belongs_to :development_user, class_name: "User", foreign_key: "development_user_id", optional: true

  validates :customer_name, presence: true
  validates :request_type, presence: true
  validates :request_content, presence: true
  validates :revenue, numericality: { greater_than_or_equal_to: 0 }
  validates :cost, numericality: { greater_than_or_equal_to: 0 }

  # enum（状態、種別）
  enum status: { 未着手: 0, 進行中: 1, 完了: 2 }
  enum request_type: { 新規: 0, 修正: 1, 追加: 2, バグ修正: 3 }
  enum request_content: { WEBアプリ制作: 0, サイト改修: 1, その他: 2 }

  # 売上・コスト差額の自動計算
  before_save :calculate_profit

  private

  def calculate_profit
    self.profit = self.revenue - self.cost
  end
end
