class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :projects, dependent: :destroy
  has_many :planning_projects, class_name: "Project", foreign_key: "planning_user_id", dependent: :nullify
  has_many :design_projects, class_name: "Project", foreign_key: "design_user_id", dependent: :nullify
  has_many :development_projects, class_name: "Project", foreign_key: "development_user_id", dependent: :nullify

  enum role: { 一般社員: 0, 管理者: 1 }

  validates :employee_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :user_name, presence: true
  validates :department, presence: true
end
