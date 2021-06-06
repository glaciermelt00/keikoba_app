require 'rails_helper'

RSpec.feature "Users", type: :feature do
  let(:user) { create(:user, :do_activate)}

  # ログイン後、フレンドリーフォワーディングされる
  scenario 'friendly forwarding after login' do
    visit edit_user_path(user)
    expect(current_path).to eq login_path

    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード',	with: user.password
    click_button 'ログイン'
    expect(current_path).to eq edit_user_path(user)
  end

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

    aggregate_failures do
      expect(current_path).to eq users_path
      expect(page).to have_selector '#error_explanation'
      expect(page).to have_selector '.field_with_errors'
    end
  end

  # 有効なユーザーは作成され、アカウントを有効化できる
  scenario 'user create with valid data and activate account' do
    # 新規登録すると、activationメールが出力され、activation_tokenが作成される
    visit root_path
    click_link '新規登録'

    expect {
      fill_in 'アカウント名', with: 'Test User'
      fill_in 'メールアドレス',	with: 'ex@ample.com'
      fill_in 'パスワード',	with: 'password'
      fill_in 'パスワード再入力',	with: 'password'
      click_button '登録する'
    }.to change(User, :count).by(1)

    expect(current_path).to eq root_path
    user = User.first
    activation_email = ActionMailer::Base.deliveries.last
    email_body = activation_email.html_part.body.encoded
    activation_token = email_body[/(?<=account_activations\/)[^\/]+/]
    expect(activation_token).to_not be_nil

    # 有効化してない状態でログインしても、flashメッセージが出力され、rootにリダイレクトされる
    click_link 'ログイン'
    fill_in 'メールアドレス',	with: 'ex@ample.com'
    fill_in 'パスワード',	with: 'password'
    click_button 'ログイン'

    aggregate_failures do
      expect(page).to have_content 'このアカウントは有効化されていません。メールの有効化リンクからアクセスしてください。'
      expect(current_path).to eq root_path
    end

    # 有効化トークンが不正な場合も、rootにリダイレクトされる
    visit edit_account_activation_path('invalid token', email: user.email)
    expect(current_path).to eq root_path

    # トークンは正しいがメールアドレスが無効な場合も、rootにリダイレクトされる
    visit edit_account_activation_path(activation_token, email: 'wrong')
    expect(current_path).to eq root_path

    # 有効化トークンが正しい場合、activatedがtrueとなり、通常はuserページにリダイレクトされる
    visit edit_account_activation_path(activation_token, email: user.email)

    aggregate_failures do
      expect(user.reload.activated?).to be true
      expect(current_path).to eq user_path(user)
    end
  end

  # アカウントが有効化されているユーザーのみ、showにアクセスできる
  scenario 'user can access user page only after activated' do
    log_in_feature(user)
    click_link 'ログアウト'

    # activateされてないユーザーは、showにアクセスできない
    unactivated_user = create(:user)
    log_in_feature(unactivated_user)
    expect(current_path).to eq root_path
  end

  # プロフィール画面を表示できる
  scenario 'user can display profile page' do
    create_list(:post, 30, user: user)
    log_in_feature(user)

    aggregate_failures do
      expect(title).to include(user.name)
      expect(page).to have_content user.name
      expect(page).to have_content user.posts.count
      expect(page).to have_selector 'ul.pagination'
    end

    user.posts[0..19].each do |post|
      expect(page).to have_content post.name
    end
  end

  # 無効なデータではログインできない
  scenario 'user cannot login with invalid data' do
    visit root_path
    click_link 'ログイン'
    fill_in 'メールアドレス',	with: 'inavalid@ex.com'
    fill_in 'パスワード',	with: 'invalid'
    click_button 'ログイン'
    expect(current_path).to eq login_path
  end

  # 有効なemail/passwordでログインできる
  scenario 'user can login with valid data' do
    log_in_feature(user)
    expect(current_path).to eq user_path(user)
  end

  # ログアウトできる
  scenario 'user can logout' do
    log_in_feature(user)
    click_link 'ログアウト'
    expect(current_path).to eq root_path
  end

  # 無効なデータでは更新できない
  scenario 'user cannot update with invalid data' do
    log_in_feature(user)
    click_link 'アカウント設定'
    expect(current_path).to eq edit_user_path(user)

    fill_in 'アカウント名',	with: ''
    fill_in 'メールアドレス',	with: 'foo@invalid'
    fill_in 'パスワード',	with: 'foo'
    fill_in 'パスワード再入力',	with: 'bar'
    click_button '変更する'

    aggregate_failures do
      expect(current_path).to eq user_path(user)
      expect(page).to have_selector 'div.alert', text: 'エラー発生： 5個'
    end
  end

  # 有効なデータで更新できる
  scenario 'user can update with valid data' do
    log_in_feature(user)
    click_link 'アカウント設定'
    expect(current_path).to eq edit_user_path(user)

    fill_in 'アカウント名',	with: 'Foo bar'
    fill_in 'メールアドレス',	with: 'foo@bar.com'
    fill_in 'パスワード',	with: ''
    fill_in 'パスワード再入力',	with: ''
    click_button '変更する'

    aggregate_failures do
      expect(current_path).to eq user_path(user)
      expect(user.reload.name).to eq 'Foo bar'
      expect(user.reload.email).to eq 'foo@bar.com'
    end
  end
end
