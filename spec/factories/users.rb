FactoryBot.define do
  factory :user, class: User do
    name                  { '山田 太郎' }
    email                 { 't-yamada@example.com' }
    password              { 'foobar' }
    password_confirmation { 'foobar' }
  end

  factory :another_user, class: User do
    name                  { '上野 花子' }
    email                 { 'h-ueno@example.com' }
    password              { 'foobar' }
    password_confirmation { 'foobar' }
  end
end
