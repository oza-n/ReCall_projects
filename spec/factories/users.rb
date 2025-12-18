FactoryBot.define do
  factory :user do
    name { 'テストユーザー' }
    email { "test#{SecureRandom.hex(4)}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
  end
end
