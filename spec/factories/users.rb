FactoryBot.define do
  factory :user do
    sequence(:name)       { |n| "Tester #{n}" }
    sequence(:email)      { |n| "tester#{n}@example.com" }
    password              { 'password' }
    password_confirmation { 'password' }

    trait :do_remember do
      after(:create, &:remember)
    end

    trait :invalid do
      name { nil }
    end

    trait :do_activate do
      after(:create, &:activate)
    end
  end
end
