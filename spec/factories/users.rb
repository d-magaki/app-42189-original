FactoryBot.define do
  factory :user do
    sequence(:employee_id) { |n| "EMP#{1000 + n}" }
    user_name { "山田 太郎" }
    department { :planning }
    role { :admin }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :planning do
      department { :planning }
    end

    trait :design do
      department { :design }
    end

    trait :development do
      department { :development }
    end

    trait :employee do
      role { :employee }
    end
  end
end
