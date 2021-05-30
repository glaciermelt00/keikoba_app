FactoryBot.define do
  factory :post do
    sequence(:name)       { |n| "Dojo ##{n}" }
    sequence(:created_at) { |n| n.days.ago }
    association :user

    factory :most_recent_post do
      created_at  { Time.zone.now }
    end
  end
end
