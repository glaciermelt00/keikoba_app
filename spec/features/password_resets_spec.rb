require 'rails_helper'

RSpec.feature "PasswordResets", type: :feature do
  # パスワードリセットの検証
  scenario 'validation of password reset' do
    user = create(:user, :do_activate)
    visit root_path
    click_link 'ログイン'
    click_link 'パスワードを忘れた方'
    expect(current_path).to eq new_password_reset_path

    # 無効なメールアドレスでは、flashメッセージが出力される
    fill_in 'メールアドレス',	with: 'foo@invalid'
    click_button '送信'

    aggregate_failures do
      expect(page).to have_selector 'div.alert-danger', text: 'このメールアドレスは登録されていません正しいメールアドレスを入力ください'
      expect(current_path).to eq password_resets_path
    end

    # 有効なメールアドレスでメールが発行される
    old_reset_digest = user.reset_digest
    fill_in 'メールアドレス',	with: user.email
    click_button '送信'

    aggregate_failures do
      expect(user.reload.reset_digest).to_not eq old_reset_digest
      expect(ActionMailer::Base.deliveries.size).to be 1
      expect(current_path).to eq root_path
    end

    # パスワード再設定ページ
    # 無効なメールアドレスでは、rootにリダイレクトされる
    reset_email = ActionMailer::Base.deliveries.last
    email_body = reset_email.html_part.body.encoded
    reset_token = email_body[/(?<=password_resets\/)[^\/]+/]
    expect(reset_token).to_not be_nil
    visit edit_password_reset_path(reset_token, email: '')
    expect(current_path).to eq root_path

    # activateされていないユーザーでは、rootにリダイレクトされる
    user.toggle!(:activated)
    visit edit_password_reset_path(reset_token, email: user.email)
    expect(current_path).to eq root_path
    user.toggle!(:activated)

    # 無効なトークンでは、rootにリダイレクトされる
    visit edit_password_reset_path('wrong token', email: user.email)
    expect(current_path).to eq root_path

    # 有効なトークンとemaildで、再設定ページにアクセスできる
    visit edit_password_reset_path(reset_token, email: user.email)

    aggregate_failures do
      expect(current_path).to eq edit_password_reset_path(reset_token)
      expect(page).to have_selector 'h2.text-center', text: '新しいパスワードを設定'
      expect(find('#email', visible: false).value).to eq user.email
    end

    # 無効なパスワードとパスワード再入力では、updateできない
    fill_in '新しいパスワード',	with: 'foobaz'
    fill_in '新しいパスワードの再入力',	with: 'barquux'
    click_button '送信'
    expect(page).to have_selector '#error_explanation'

    # パスワードが空では、updateできない
    fill_in '新しいパスワード',	with: ''
    fill_in '新しいパスワードの再入力',	with: ''
    click_button '送信'
    expect(page).to have_selector '#error_explanation'

    # 有効なパスワードとパスワード確認で、ログインでき、reset_digestがからにな利、userページにリダイレクトされる
    fill_in '新しいパスワード',	with: 'foobaz'
    fill_in '新しいパスワードの再入力',	with: 'foobaz'
    click_button '送信'

    aggregate_failures do
      expect(page).to have_content 'ログアウト'
      expect(current_path).to eq user_path(user)
      expect(user.reload.reset_digest).to be_nil
    end
  end

  # トークンの有効期限が切れると、パスワードを再設定できない
  scenario 'cannot reset password after the expiration date of reset token' do
    user = create(:user, :do_activate)
    visit root_path
    click_link 'ログイン'
    click_link 'パスワードを忘れた方'
    fill_in 'メールアドレス',	with: user.email
    click_button '送信'

    reset_email = ActionMailer::Base.deliveries.last
    email_body = reset_email.html_part.body.encoded
    reset_token = email_body[/(?<=password_resets\/)[^\/]+/]

    user.update_attribute(:reset_sent_at, 3.hours.ago)
    visit edit_password_reset_path(reset_token, email: user.email)
    save_and_open_page
    expect(page).to have_selector 'div.alert-danger', text: '有効期限が切れているため、パスワードを再設定できませんでした'
  end
end
