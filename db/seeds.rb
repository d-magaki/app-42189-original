puts "✅ シードデータ登録開始..."

Project.destroy_all
User.destroy_all

# 管理者
admin = User.create!(
  email: "admin@example.com",
  employee_id: "EMP9999",
  user_name: "管理者ユーザー",
  department: :planning,
  role: :admin,
  password: "password123",
  password_confirmation: "password123"
)

# 各部署ごとのユーザーを3名ずつ
planner_users = 3.times.map do |i|
  User.create!(
    email: "planner#{i + 1}@example.com",
    employee_id: "EMP1#{i + 1}01",
    user_name: "企画#{i + 1}号",
    department: :planning,
    role: :employee,
    password: "password123",
    password_confirmation: "password123"
  )
end

designer_users = 3.times.map do |i|
  User.create!(
    email: "designer#{i + 1}@example.com",
    employee_id: "EMP2#{i + 1}01",
    user_name: "設計#{i + 1}号",
    department: :design,
    role: :employee,
    password: "password123",
    password_confirmation: "password123"
  )
end

developer_users = 3.times.map do |i|
  User.create!(
    email: "developer#{i + 1}@example.com",
    employee_id: "EMP3#{i + 1}01",
    user_name: "開発#{i + 1}号",
    department: :development,
    role: :employee,
    password: "password123",
    password_confirmation: "password123"
  )
end

puts "✅ ユーザー作成完了"

# 各工程ごとの案件を生成
3.times do |i|
  # 企画未着手
  Project.create!(
    customer_name: "企画未着手案件#{i + 1}",
    sales_office: "宮城",
    sales_representative: "営業#{i + 1}郎",
    request_type: :新規依頼,
    request_content: :WEBアプリ制作,
    order_date: Date.today - 10,
    due_date: Date.today + 20,
    status: :未着手,
    planning_user: nil,
    user: admin
  )

  # 企画進行中
  Project.create!(
    customer_name: "企画進行中案件#{i + 1}",
    sales_office: "東京",
    sales_representative: "営業#{i + 4}郎",
    request_type: :修正依頼,
    request_content: :WEBデザイン制作,
    order_date: Date.today - 15,
    due_date: Date.today + 10,
    status: :進行中,
    planning_user: planner_users[i],
    planning_start_date: Date.today - 5,
    user: admin
  )

  # 設計未着手
  Project.create!(
    customer_name: "設計未着手案件#{i + 1}",
    sales_office: "大阪",
    sales_representative: "営業#{i + 7}郎",
    request_type: :バグ修正,
    request_content: :システム構築,
    order_date: Date.today - 20,
    due_date: Date.today + 5,
    status: :未着手,
    planning_user: planner_users[i],
    planning_start_date: Date.today - 10,
    planning_end_date: Date.today - 5,
    design_user: nil,
    user: admin
  )

  # 設計進行中
  Project.create!(
    customer_name: "設計進行中案件#{i + 1}",
    sales_office: "名古屋",
    sales_representative: "営業#{i + 10}郎",
    request_type: :追加依頼,
    request_content: :データ解析,
    order_date: Date.today - 30,
    due_date: Date.today + 7,
    status: :進行中,
    planning_user: planner_users[i],
    planning_start_date: Date.today - 20,
    planning_end_date: Date.today - 15,
    design_user: designer_users[i],
    design_start_date: Date.today - 10,
    user: admin
  )

  # 開発未着手
  Project.create!(
    customer_name: "開発未着手案件#{i + 1}",
    sales_office: "福岡",
    sales_representative: "営業#{i + 13}郎",
    request_type: :新規依頼,
    request_content: :スマホアプリ制作,
    order_date: Date.today - 25,
    due_date: Date.today + 14,
    status: :未着手,
    planning_user: planner_users[i],
    planning_start_date: Date.today - 20,
    planning_end_date: Date.today - 15,
    design_user: designer_users[i],
    design_start_date: Date.today - 14,
    design_end_date: Date.today - 10,
    development_user: nil,
    user: admin
  )

  # 開発進行中
  Project.create!(
    customer_name: "開発進行中案件#{i + 1}",
    sales_office: "札幌",
    sales_representative: "営業#{i + 16}郎",
    request_type: :その他＿依頼,
    request_content: :その他＿内容,
    order_date: Date.today - 40,
    due_date: Date.today + 3,
    status: :進行中,
    planning_user: planner_users[i],
    planning_start_date: Date.today - 30,
    planning_end_date: Date.today - 25,
    design_user: designer_users[i],
    design_start_date: Date.today - 24,
    design_end_date: Date.today - 20,
    development_user: developer_users[i],
    development_start_date: Date.today - 5,
    user: admin
  )
end

# 完了済み案件を数件追加
3.times do |i|
  Project.create!(
    customer_name: "完了済み案件#{i + 1}",
    sales_office: "渋谷",
    sales_representative: "営業完#{i + 1}",
    request_type: :バグ修正,
    request_content: :WEBアプリ制作,
    order_date: Date.today - 60,
    due_date: Date.today - 10,
    status: :完了,
    planning_user: planner_users[i % 3],
    planning_start_date: Date.today - 50,
    planning_end_date: Date.today - 45,
    design_user: designer_users[i % 3],
    design_start_date: Date.today - 44,
    design_end_date: Date.today - 40,
    development_user: developer_users[i % 3],
    development_start_date: Date.today - 39,
    development_end_date: Date.today - 30,
    user: admin
  )
end

puts "✅ 各工程の未着手・進行中・完了案件データを生成しました！"
