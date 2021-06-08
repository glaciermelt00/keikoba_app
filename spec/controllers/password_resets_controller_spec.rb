require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  describe '#new' do
    # 正常にレスポンスを返すこと
    it 'responds successfully' do
      get :new
      expect(response).to be_successful
    end

    # 200レスポンスを返すこと
    it 'returns a 200 response' do
      get :new
      expect(response).to have_http_status '200'
    end
  end

  describe '#create' do
    before do
      @user = create(:user)
    end

    # 有効な属性値の場合
    context 'with valid attributes' do
      # infoフラッシュメッセージが出力されること
      it 'prints info flash message' do
        reset_params = { email: @user.email }
        post :create, params: { password_reset: reset_params }
        expect(flash[:info]).to eq '再設定用のURLを記載したメールを送信しました'
      end

      # rootにリダイレクトすること
      it 'redirects to user page' do
        reset_params = { email: @user.email }
        post :create, params: { password_reset: reset_params }
        expect(response).to redirect_to root_path
      end
    end

    # 無効な属性値の場合
    context 'with invalid attributes' do
      # dangerフラッシュメッセージが出力されること
      it 'prints info flash message' do
        reset_params = { email: @user.email }
        post :create, params: { password_reset: reset_params }
        expect(flash[:info]).to eq '再設定用のURLを記載したメールを送信しました'
      end
    end
  end

  describe '#edit' do
    # activateされたユーザーとして
    context 'as an activated user' do
      before do
        @user = create(:user, :do_activate)
        @user.create_reset_digest
      end

      # 正常にレスポンスを返すこと
      it 'responds successfully' do
        reset_params = { id: @user.reset_token, email: @user.email }
        get :edit, params: reset_params
        expect(response).to be_successful
      end

      # 200レスポンスを返すこと
      it 'returns a 200 response' do
        reset_params = { id: @user.reset_token, email: @user.email }
        get :edit, params: reset_params
        expect(response).to have_http_status '200'
      end
    end

    # activateされていないユーザーとして
    context 'as an unactivated user' do
      before do
        @user = create(:user)
        @user.create_reset_digest
      end

      # rootへリダイレクトすること
      it 'redirects to root' do
        reset_params = { id: @user.reset_token, email: @user.email }
        get :edit, params: reset_params
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#update' do
    # activateされたユーザーとして
    context 'as an activated user' do
      before do
        @user = create(:user, :do_activate)
        @user.create_reset_digest
      end

      # リセットdigestがnilになること
      it 'updates reset_digest to nil' do
        reset_params = {
          password: 'newpass',
          password_confirmation: 'newpass'
        }
        patch :update, params: {
          id: @user.reset_token,
          email: @user.email,
          user: reset_params
        }
        expect(@user.reload.reset_digest).to be_nil
      end
    end

    # activateされてないユーザーとして
    context 'as an unactivated user' do
      before do
        @user = create(:user)
        @user.create_reset_digest
      end

      # rootへリダイレクトすること
      it 'redirects to root' do
        reset_params = {
          password: 'newpass',
          password_confirmation: 'newpass'
        }
        patch :update, params: {
          id: @user.reset_token,
          email: @user.email,
          user: reset_params
        }
        expect(response).to redirect_to root_path
      end
    end
  end
end
