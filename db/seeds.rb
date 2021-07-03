# メインのサンプルユーザーを1人作成する
User.create!(name:  "Example User",
  email: "example@railstutorial.org",
  password:              "foobar",
  password_confirmation: "foobar",
  admin: true,
  activated: true,
  activated_at: Time.zone.now)

# 追加のユーザーをまとめて生成する
99.times do |n|
name  = Gimei.name.kanji
email = "example-#{n+1}@railstutorial.org"
password = "password"
User.create!(name:  name,
    email: email,
    password:              password,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now)
end

# ユーザーの一部を対象にPostを生成する。
users = User.order(:created_at).take(10)
name_prefix = %W( #{}
                  総合
                  記念
                  ナショナル
                  第一
                  第二
                  中央
                  地域 )
name_body = %w( スポーツ会館
                体育室
                スポーツセンター
                武道館
                体育館
                アリーナ
                競技場
                運動場
                公園
                スポーツハウス
                スポーツプラザ )
100.times do
  gimei_address = Gimei.address
  name = "#{gimei_address.town.kanji}#{name_prefix.sample}#{name_body.sample}"
  address = gimei_address.kanji
  users.sample.posts.create!(name: name, address: address)
end