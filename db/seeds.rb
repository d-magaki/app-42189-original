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
  6.times do |j|
    revenue = rand(600_000..1_200_000)
    cost = rand(300_000..800_000)
    profit = revenue - cost

    Project.create!(
      customer_name: %w[企画未着手案件 企画進行中案件 設計未着手案件 設計進行中案件 開発未着手案件 開発進行中案件][j] + "#{i + 1}",
      sales_office: %w[宮城 東京 大阪 名古屋 福岡 札建][j],
      sales_representative: "営業#{i + j + 1}郎",
      request_type: Project.request_types.keys[j % Project.request_types.keys.size],
      request_content: Project.request_contents.keys[j % Project.request_contents.keys.size],
      order_date: Date.today - rand(10..40),
      due_date: Date.today + rand(3..20),
      status: j.even? ? :未着手 : :進行中,
      planning_user: j >= 2 ? planner_users[i % 3] : nil,
      planning_start_date: j >= 1 ? Date.today - rand(20..30) : nil,
      planning_end_date: j >= 3 ? Date.today - rand(15..20) : nil,
      design_user: j >= 3 ? designer_users[i % 3] : nil,
      design_start_date: j >= 3 ? Date.today - rand(14..24) : nil,
      design_end_date: j >= 4 ? Date.today - rand(10..20) : nil,
      development_user: j == 5 ? developer_users[i % 3] : nil,
      development_start_date: j == 5 ? Date.today - rand(3..10) : nil,
      revenue: revenue,
      cost: cost,
      profit: profit,
      user: admin
    )
  end
end

# 完了済み案件
3.times do |i|
  revenue = rand(1_000_000..1_500_000)
  cost = rand(700_000..1_100_000)
  profit = revenue - cost

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
    revenue: revenue,
    cost: cost,
    profit: profit,
    user: admin
  )
end

puts "✅ 各工程の未着手・進行中・完了案件データを生成しました！"
