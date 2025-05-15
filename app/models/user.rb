class User < ApplicationRecord
  # Devise認証モジュール
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 関連
  has_many :projects, dependent: :destroy
  has_many :planning_projects, class_name: "Project", foreign_key: "planning_user_id", dependent: :nullify
  has_many :design_projects, class_name: "Project", foreign_key: "design_user_id", dependent: :nullify
  has_many :development_projects, class_name: "Project", foreign_key: "development_user_id", dependent: :nullify

  # enum定義
  enum role: { 一般社員: 0, 管理者: 1 }
  enum department: {
    企画部: "企画部",
    情報設計部: "情報設計部",
    開発部: "開発部"
  }

  # バリデーション
  validates :employee_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :user_name, presence: true
  validates :department, presence: true
end
