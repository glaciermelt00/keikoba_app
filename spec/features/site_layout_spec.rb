require 'rails_helper'

RSpec.feature "SiteLayout", type: :feature do
  # 未ログインの場合、適切なリンクが生成されていること
  scenario 'layout links are created before login' do
    visit root_path
    expect(current_path).to eq root_path
    expect(page).to have_selector "a[href='/']", count: 2
    expect(page).to have_selector "a[href='/login']"
    expect(page).to have_selector "a[href='/signup']"
  end

  # ログイン後、適切なリンクが生成されていること
  scenario 'layout links are created after login' do
    user = create(:user, :do_activate)

    visit root_path
    click_link 'ログイン'
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード',	with: user.password
    click_button 'ログイン'
    expect(current_path).to eq user_path(user)

    expect(page).to have_selector "a[href='/users/#{user.id}/edit']"
    expect(page).to have_selector "a[href='/users/#{user.id}']"
    expect(page).to have_selector "a[href='/posts/new']"
  end
end