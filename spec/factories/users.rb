FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password_digest { BCrypt::Password.create("secret_password") }
  end
end
