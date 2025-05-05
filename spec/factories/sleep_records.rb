FactoryBot.define do
  factory :sleep_record do
    user
    start_time { Faker::Time.between(from: 10.hours.ago, to: Time.current) }
    end_time { Faker::Time.between(from: start_time, to: 10.hours.from_now) }
  end
end
