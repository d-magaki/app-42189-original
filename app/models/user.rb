class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :projects, dependent: :destroy

  enum department: {
    企画部: 0,
    情報設計部: 1,
    開発部: 2
  }

  enum role: {
    一般社員: 0,
    管理者: 1
  }
end
