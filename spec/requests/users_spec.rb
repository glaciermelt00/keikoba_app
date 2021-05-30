require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before(:each) do
    @user = FactoryBot.create(:user)
    @another_user = FactoryBot.create(:user)
  end

  describe 'GET /signup' do
    it 'リクエストが成功する。タイトルが新規登録である' do
      get '/signup'
      expect(response).to have_http_status(:success)
      expect(response.body).to match('新規登録')
    end
  end

  describe 'GET /index' do
    context '未ログインの場合' do
      it '/loginにリダイレクトされる' do
        get '/users'
        expect(response).to redirect_to login_url
      end
    end
  end

  describe 'GET /edit' do
    context '未ログインの場合' do
      it 'flashメッセージが出力される。/loginにリダイレクトされる。' do
        get format('/users/%<x>s/edit', x: @user.id)
        expect(flash).to_not be_empty
        expect(response).to redirect_to login_url
      end
    end

    context '異なるユーザーの場合' do
      it 'flashメッセージが出力される。/loginにリダイレクトされる。' do
        get '/login'
        log_in_as(@another_user)
        get format('/users/%<x>s/edit', x: @user.id)
        expect(flash).to_not be_empty
        expect(response).to redirect_to login_url
      end
    end

    context 'Loginに成功した場合' do
      it 'フォワーディングURLを削除する' do
        get format('/users/%<x>s/edit', x: @user.id)
        expect(session[:forwarding_url]).to eq edit_user_url(@user)
        log_in_as(@user)
        expect(session[:forwarding_url]).to be_nil
      end
    end
  end

  describe 'PATCH /update' do
    # おそらく、patch行がうまく働いてない気がする
    it 'web経由でadmin属性はupdateされない', type: :feature do
      get '/login'
      log_in_as(@another_user)
      expect(@another_user).to_not be_admin
      patch user_path(@another_user), params: { user: {
        password: 'password', 
        password_confirmation: 'password', 
        admin: true
      } }
      expect(@another_user.reload).to_not be_admin
    end

    context '未ログインの場合', type: :feature do
      it 'flashメッセージが出力される。/loginにリダイレクトされる' do
        patch user_path(@user), params: { user: {
          name: @user.name,
          email: @user.email
        } }
        expect(flash).to_not be_empty
        expect(response).to redirect_to login_url
      end
    end

    context '異なるユーザーの場合' do
      it 'flashメッセージが出力される。/loginにリダイレクトされる。' do
        get '/login'
        log_in_as(@another_user)
        patch user_path(@user), params: { user: {
          name: @user.name,
          email: @user.email
        } }
        expect(flash).to_not be_empty
        expect(response).to redirect_to login_url
      end
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/users/show'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /create' do
    it 'returns http success' do
      get '/users/create'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /destroy' do
    it 'returns http success' do
      get '/users/destroy'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /guest' do
    it 'returns http success' do
      get '/users/guest'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /following' do
    it 'returns http success' do
      get '/users/following'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /followers' do
    it 'returns http success' do
      get '/users/followers'
      expect(response).to have_http_status(:success)
    end
  end
end
