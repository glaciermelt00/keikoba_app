FactoryBot.define do
  factory :user do
    name                  { '山田 太郎' }
    email                 { 't-yamada@example.com' }
    password              { 'password' }
    password_confirmation { 'password' }
    admin                 { true }
    activated             { true }
    activated_at          { Time.zone.now }
  end

  factory :another_user, class: User do
    name                  { '上野 花子' }
    email                 { 'h-ueno@example.com' }
    password              { 'password' }
    password_confirmation { 'password' }
    activated             { true }
    activated_at          { Time.zone.now }
  end
end
