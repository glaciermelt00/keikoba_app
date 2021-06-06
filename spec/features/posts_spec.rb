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

  scenario 'post interface', js: true do
    user = create(:user, :do_activate)

    visit root_path
    click_link 'ログイン'
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード',	with: user.password
    click_button 'ログイン'
    find(".fa-edit").click
    expect(page).to have_selector 'h2', text: '新規投稿'

    # 無効なpostは作成されない
    expect {
      fill_in '名称', with: ''
      click_button '投稿する'
    }.to_not change(user.posts, :count)
    expect(page).to have_selector 'div.alert-danger', text: 'エラー発生： 1個'

    # 有効なpostは作成される
    expect {
      fill_in '名称', with: 'Test Post'
      attach_file '画像アップロード', "#{Rails.root}/spec/fixtures/images/cat_5kb.jpg"
      click_button '投稿する'
    }.to change(user.posts, :count).by(1)
    expect(page).to have_selector 'div.alert-success', text: '投稿できました！'
    post_name = user.posts.last.name
    expect(page).to have_selector 'a.card-title', text: post_name
    expect(page).to have_selector "img[src$='cat_5kb.jpg']"

    # 投稿を削除できる
    click_link user.posts.last.name
    expect(page).to have_selector 'a.btn-danger', text: '削除する'
    expect {
      click_link '削除する'
      expect(page.accept_confirm).to eq "削除しますか？"
      expect(page).to have_selector 'div.alert-success', text: '投稿が削除されました'
    }.to change(user.posts, :count).by(-1)

    expect(current_path).to eq user_path(user)
    expect(page).to_not have_selector 'a', text: post_name

    # 他のユーザーのpostは削除できない
    other_user = create(:user, :do_activate)
    create_list(:post, 3, user: other_user)

    find(".fa-users").click
    click_link other_user.name
    click_link other_user.posts.last.name
    expect(current_path).to eq post_path(other_user.posts.last)
    expect(page).to_not have_content '削除する'
  end

  # 投稿数をカウントできる
  scenario 'can count posts' do
    user = create(:user, :do_activate)
    create_list(:post, 50, user: user)

    visit root_path
    click_link 'ログイン'
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード',	with: user.password
    click_button 'ログイン'

    expect(page).to have_selector 'h3', text: "投稿 (#{user.posts.count}件)"
    click_link 'ログアウト'

    # postしていない場合は0件、postしたら1件が表示される
    other_user = create(:user, :do_activate)

    click_link 'ログイン'
    fill_in 'メールアドレス', with: other_user.email
    fill_in 'パスワード',	with: other_user.password
    click_button 'ログイン'
    expect(page).to have_selector 'h3', text: "投稿 (0件)"

    create(:post, user: other_user)
    visit current_path
    expect(page).to have_selector 'h3', text: "投稿 (1件)"
  end
end
