class Project < ApplicationRecord
  belongs_to :user, optional: true
  has_many_attached :attachments
  belongs_to :planning_user, class_name: "User", optional: true
  belongs_to :design_user, class_name: "User", optional: true
  belongs_to :development_user, class_name: "User", optional: true

  attr_accessor :employee_id

  enum status: { 未着手: 0, 進行中: 1, 完了: 2 }

  enum request_type: {
    新規依頼: 0,
    修正依頼: 1,
    追加依頼: 2,
    バグ修正: 3,
    その他＿依頼: 4
  }

  enum request_content: {
    WEBアプリ制作: 0,
    WEBデザイン制作: 1,
    スマホアプリ制作: 2,
    システム構築: 3,
    データ解析: 4,
    その他＿内容: 5
  }

  validates :customer_name, :sales_office, :sales_representative,
            :request_type, :request_content, :order_date, :due_date,
            :status, presence: true

  validates :revenue, :cost, :profit, numericality: { allow_nil: true }
end