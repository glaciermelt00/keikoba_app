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
    expect(page).to have_selector 'div.alert-danger', text: 'このメールアドレスは登録されていません正しいメールアドレスを入力ください'
    expect(current_path).to eq password_resets_path

    # 有効なメールアドレスでメールが発行される
    old_reset_digest = user.reset_digest
    fill_in 'メールアドレス',	with: user.email
    click_button '送信'
    expect(user.reload.reset_digest).to_not eq old_reset_digest
    expect(ActionMailer::Base.deliveries.size).to be 1
    expect(current_path).to eq root_path

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
  end
end