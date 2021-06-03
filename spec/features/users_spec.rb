require 'rails_helper'

RSpec.feature "Users", type: :feature do
  # 無効なユーザーは作成されない
  scenario 'user cannot create with invalid data' do
    visit root_path
    click_link '新規登録'
    expect {
      fill_in 'アカウント名', with: ''
      fill_in 'メールアドレス',	with: 'ex@ample.com'
      fill_in 'パスワード',	with: 'foo'
      fill_in 'パスワード再入力',	with: 'bar'
      click_button '登録する'
    }.to_not change(User, :count)

    expect(current_path).to eq users_path
    expect(page).to have_selector '#error_explanation'
    expect(page).to have_selector '.field_with_errors'
  end

  # 有効なユーザーは作成され、アカウントを有効化できる
  scenario 'user create with valid data and activate account' do
    visit root_path
    click_link '新規登録'
    expect {
      fill_in 'アカウント名', with: 'Test User'
      fill_in 'メールアドレス',	with: 'ex@ample.com'
      fill_in 'パスワード',	with: 'password'
      fill_in 'パスワード再入力',	with: 'password'
      click_button '登録する'
    }.to change(User, :count).by(1)

    # ここから続きを入力する
  end

  # ログイン後、フレンドリーフォワーディングされる
  scenario 'friendly forwarding after login' do
    user = create(:user, :do_activate)

    visit edit_user_path(user)
    expect(current_path).to eq login_path

    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード',	with: user.password
    click_button 'ログイン'

    expect(current_path).to eq edit_user_path(user)
  end
end