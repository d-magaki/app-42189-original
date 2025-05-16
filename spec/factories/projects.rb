FactoryBot.define do
  factory :project do
    customer_name { "株式会社テスト" }
    sales_office { "東京支社" }
    sales_representative { "山田太郎" }
    request_type { :新規依頼 }
    request_content { :WEBアプリ制作 }
    order_date { Date.today }
    due_date { Date.today + 7 }
    status { :未着手 }
    revenue { 100_000 }
    cost { 50_000 }
    profit { 50_000 }
    remarks { "備考です" }

    user

    transient do
      planning_user_trait { [] }
      design_user_trait { [] }
      development_user_trait { [] }
    end

    planning_user { association :user, *planning_user_trait }
    design_user   { association :user, *design_user_trait }
    development_user { association :user, *development_user_trait }
  end
end
