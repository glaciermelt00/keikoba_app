require 'rails_helper'

RSpec.feature "Posts", type: :feature do
  # ユーザーは新しいpostを作成する
  scenario 'user creates a new post' do
    user = create(:user, :do_activate)

    visit root_path
    click_link 'ログイン'
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード',	with: user.password
    click_button 'ログイン'

    expect{
      find(".fa-edit").click
      fill_in '名称', with: 'Test Dojo'
      click_button '投稿する'

      expect(page).to have_content '投稿できました！'
      expect(page).to have_content 'Test Dojo'
      expect(page).to have_content "#{user.name}"
    }.to change(user.posts, :count).by(1)
  end

  # ユーザーは5MBを超えるサイズの画像ではpostできない
  scenario 'user do not create a post includes a image with more than 5MB', js: true do
    user = create(:user, :do_activate)

    visit root_path
    click_link 'ログイン'
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード',	with: user.password
    click_button 'ログイン'

    find(".fa-edit").click
    fill_in '名称', with: 'Test Dojo 2'
    attach_file '画像アップロード', "#{Rails.root}/spec/fixtures/images/024.jpg"

    expect(page.driver.browser.switch_to.alert.text).to eq '画像のサイズが5MBを超えています。5MB未満の画像を選択して下さい。'
  end
end
