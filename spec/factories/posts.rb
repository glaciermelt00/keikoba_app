FactoryBot.define do
  factory :post do
    sequence(:name)       { |n| "test#{n}@example.com" }
    user_id               { 1 }
    sequence(:created_at) { |n| n.days.ago }
  end

  factory :most_recent_post, class: Post do
    name        { 'test@example.com' }
    user_id     { 1 }
    created_at  { Time.zone.now }
  end
end
