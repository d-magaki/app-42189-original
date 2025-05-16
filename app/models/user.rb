class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :projects, dependent: :destroy

  enum department: {
    planning: 0,
    design: 1,
    development: 2
  }

  enum role: {
    employee: 0,
    admin: 1
  }

  # バリデーション
  validates :employee_id, presence: true, uniqueness: true
  validates :user_name, :department, :role, presence: true
end
