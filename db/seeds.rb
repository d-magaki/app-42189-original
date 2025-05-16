puts "✅ シードデータ登録開始..."

# 共通ユーザー
admin_user = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.employee_id = "EMP9999"
  user.user_name = "管理者ユーザー"
  user.department = :planning
  user.role = :admin
  user.password = "password123"
  user.password_confirmation = "password123"
end

# 各部署の一般ユーザー
planner = User.find_or_create_by!(email: "planner@example.com") do |user|
  user.employee_id = "EMP1001"
  user.user_name = "企画担当"
  user.department = :planning
  user.role = :employee
  user.password = "password123"
  user.password_confirmation = "password123"
end

designer = User.find_or_create_by!(email: "designer@example.com") do |user|
  user.employee_id = "EMP1002"
  user.user_name = "設計担当"
  user.department = :design
  user.role = :employee
  user.password = "password123"
  user.password_confirmation = "password123"
end

developer = User.find_or_create_by!(email: "developer@example.com") do |user|
  user.employee_id = "EMP1003"
  user.user_name = "開発担当"
  user.department = :development
  user.role = :employee
  user.password = "password123"
  user.password_confirmation = "password123"
end

puts "✅ ユーザー作成完了"

# 案件データをクリア（必要に応じて）
Project.destroy_all
puts "🧹 既存の案件データを削除"

# 案件データ作成
Project.create!(
  customer_name: "企画未着手株式会社",
  sales_office: "東京",
  sales_representative: "営業太郎",
  request_type: :新規依頼,
  request_content: :WEBアプリ制作,
  order_date: Date.today - 10,
  due_date: Date.today + 20,
  status: :未着手,
  planning_user: planner,
  user: admin_user
)

Project.create!(
  customer_name: "企画進行中株式会社",
  sales_office: "東京",
  sales_representative: "営業次郎",
  request_type: :修正依頼,
  request_content: :WEBデザイン制作,
  order_date: Date.today - 15,
  due_date: Date.today + 10,
  status: :進行中,
  planning_user: planner,
  planning_start_date: Date.today - 5,
  user: admin_user
)

Project.create!(
  customer_name: "設計未着手株式会社",
  sales_office: "大阪",
  sales_representative: "営業三郎",
  request_type: :バグ修正,
  request_content: :システム構築,
  order_date: Date.today - 20,
  due_date: Date.today + 5,
  status: :未着手,
  planning_user: planner,
  planning_start_date: Date.today - 10,
  planning_end_date: Date.today - 5,
  design_user: designer,
  user: admin_user
)

Project.create!(
  customer_name: "設計進行中株式会社",
  sales_office: "名古屋",
  sales_representative: "営業四郎",
  request_type: :追加依頼,
  request_content: :データ解析,
  order_date: Date.today - 30,
  due_date: Date.today + 7,
  status: :進行中,
  planning_user: planner,
  planning_start_date: Date.today - 20,
  planning_end_date: Date.today - 15,
  design_user: designer,
  design_start_date: Date.today - 10,
  user: admin_user
)

Project.create!(
  customer_name: "開発未着手株式会社",
  sales_office: "福岡",
  sales_representative: "営業五郎",
  request_type: :新規依頼,
  request_content: :スマホアプリ制作,
  order_date: Date.today - 25,
  due_date: Date.today + 14,
  status: :未着手,
  planning_user: planner,
  planning_start_date: Date.today - 20,
  planning_end_date: Date.today - 15,
  design_user: designer,
  design_start_date: Date.today - 14,
  design_end_date: Date.today - 10,
  development_user: developer,
  user: admin_user
)

Project.create!(
  customer_name: "開発進行中株式会社",
  sales_office: "札幌",
  sales_representative: "営業六郎",
  request_type: :その他＿依頼,
  request_content: :その他＿内容,
  order_date: Date.today - 40,
  due_date: Date.today + 3,
  status: :進行中,
  planning_user: planner,
  planning_start_date: Date.today - 30,
  planning_end_date: Date.today - 25,
  design_user: designer,
  design_start_date: Date.today - 24,
  design_end_date: Date.today - 20,
  development_user: developer,
  development_start_date: Date.today - 5,
  user: admin_user
)

puts "✅ 各部署用の進行状態データを追加しました！"
