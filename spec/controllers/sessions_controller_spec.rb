require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
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
    # activateされたユーザーとして
    context 'as an activated user' do
      before do
        @user = create(:user, :do_activate)
      end

      # 有効な属性値の場合
      context 'with valid attributes' do
        # ログインできること
        it 'logs in' do
          session_params = { email: @user.email, password: @user.password }
          post :create, params: { session: session_params }
          expect(session[:user_id]).to eq @user.id
        end
      end

      # 無効な属性値の場合
      context 'with invalid attributes' do
        # ログインできないこと
        it 'does not log in' do
          session_params = { email: '', password: @user.password }
          post :create, params: { session: session_params }
          expect(session[:user_id]).to be_nil
        end
      end
    end

    # activateされてないユーザーとして
    context 'as an unactivated user' do
      before do
        @user = create(:user)
      end

      # 有効な属性値の場合
      context 'with valid attributes' do
        # ログインできないこと
        it 'does not log in' do
          session_params = { email: @user.email, password: @user.password }
          post :create, params: { session: session_params }
          expect(session[:user_id]).to be_nil
        end
      end
    end
  end

  describe '#destroy' do
    before do
      @user = create(:user)
    end

    # ログアウトできること
    it 'logs out' do
      log_in_as @user
      delete :destroy
      expect(session[:user_id]).to be_nil
    end
  end
end
