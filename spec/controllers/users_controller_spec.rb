require 'rails_helper'

RSpec.describe UsersController, type: :controller do
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
    # 有効な属性値の場合
    context 'with valid attributes' do
      # ユーザーを追加できること
      it 'adds a user' do
        user_params = attributes_for(:user)
        expect do
          post :create, params: { user: user_params }
        end.to change(User, :count).by(1)
      end
    end

    # 無効な属性値の場合
    context 'with invalid attributes' do
      # ユーザーを追加できないこと
      it 'does not add a user' do
        user_params = attributes_for(:user, :invalid)
        expect do
          post :create, params: { user: user_params }
        end.to_not change(User, :count)
      end
    end
  end

  describe '#show' do
    before do
      @user = create(:user, :do_activate)
    end

    # 正常にレスポンスを返すこと
    it 'responds successfully' do
      get :show, params: { id: @user.id }
      expect(response).to be_successful
    end

    # 200レスポンスを返すこと
    it 'returns a 200 response' do
      get :show, params: { id: @user.id }
      expect(response).to have_http_status '200'
    end
  end

  describe '#index' do
    before do
      @user = create(:user, :do_activate)
    end

    # 正常にレスポンスを返すこと
    it 'responds successfully' do
      get :index
      expect(response).to be_successful
    end

    # 200レスポンスを返すこと
    it 'returns a 200 response' do
      get :index
      expect(response).to have_http_status '200'
    end
  end

  describe '#edit' do
    # 認可されたユーザーとして
    context 'as an authorized user' do
      before do
        @user = create(:user, :do_activate)
      end

      # 正常にレスポンスを返すこと
      it 'responds successfully' do
        log_in_as @user
        get :edit, params: { id: @user.id }
        expect(response).to be_successful
      end
    end

    # 認可されていないユーザーとして
    context 'as an unauthorized user' do
      before do
        @user = create(:user)
        @other_user = create(:user)
      end

      # rootにリダイレクトすること
      it 'redirects to root' do
        log_in_as @user
        get :edit, params: { id: @other_user.id }
        expect(response).to redirect_to root_path
      end
    end

    # ゲストとして
    context 'as a guest' do
      before do
        @other_user = create(:user)
      end

      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        get :edit, params: { id: @other_user.id }
        expect(response).to have_http_status '302'
      end

      # dangerフラッシュメッセージが出力すること
      it 'prints danger flash message' do
        get :edit, params: { id: @other_user.id }
        expect(flash[:danger]).to eq 'ログインしてください'
      end

      # ログイン画面にリダイレクトすること
      it 'redirects to the login page' do
        get :edit, params: { id: @other_user.id }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#update' do
    # 認可されたユーザーとして
    context 'as an authorized user' do
      before do
        @user = create(:user)
      end

      # ユーザー情報を更新できること
      it 'updates a post' do
        user_params = attributes_for(:user, name: 'New User Name')
        log_in_as @user
        patch :update, params: { id: @user.id, user: user_params }
        expect(@user.reload.name).to eq 'New User Name'
      end
    end

    # 認可されていないユーザーとして
    context 'as an unauthorized user' do
      before do
        @user = create(:user, :do_activate)
        @other_user = create(:user, :do_activate, name: 'Same Old Name')
      end

      # ユーザー情報を更新できないこと
      it 'does not update the post' do
        user_params = attributes_for(:user, name: 'New Name')
        log_in_as @user
        patch :update, params: { id: @other_user.id, user: user_params }
        expect(@other_user.reload.name).to eq 'Same Old Name'
      end

      # web経由ではadmin属性をtrueにできない
      it ' cannot change admin attribute to true' do
        user_params = attributes_for(:user, admin: true)
        log_in_as @other_user
        patch :update, params: { id: @other_user.id, user: user_params }
        expect(@other_user.reload.admin).to_not be true
      end

      # rootへリダイレクトすること
      it 'redirects to root' do
        user_params = attributes_for(:user)
        log_in_as @user
        patch :update, params: { id: @other_user.id, post: user_params }
        expect(response).to redirect_to root_path
      end
    end

    # ゲストとして
    context 'as a guest' do
      before do
        @other_user = create(:user)
      end

      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        user_params = attributes_for(:user)
        patch :update, params: { id: @other_user.id, user: user_params }
        expect(response).to have_http_status '302'
      end

      # dangerフラッシュメッセージが出力すること
      it 'prints danger flash message' do
        user_params = attributes_for(:user)
        patch :update, params: { id: @other_user.id, user: user_params }
        expect(flash[:danger]).to eq 'ログインしてください'
      end

      # ログイン画面にリダイレクトすること
      it 'redirects to the login page' do
        user_params = attributes_for(:user)
        patch :update, params: { id: @other_user.id, user: user_params }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#destroy' do
    # 認可されたユーザーとして
    context 'as an authorized user' do
      before do
        @user = create(:user, admin: true)
        @other_user = create(:user)
      end

      # 投稿を削除できること
      it 'deletes a post' do
        log_in_as @user
        expect do
          delete :destroy, params: { id: @other_user.id }
        end.to change(User, :count).by(-1)
      end
    end

    # 認可されていないユーザーとして
    context 'as an unauthorized user' do
      before do
        @user = create(:user)
        @other_user = create(:user)
      end

      # 投稿を削除できないこと
      it 'does not delete the post' do
        log_in_as @user
        expect do
          delete :destroy, params: { id: @other_user.id }
        end.to_not change(User, :count)
      end

      # rootへリダイレクトすること
      it 'redirects to root' do
        log_in_as @user
        delete :destroy, params: { id: @other_user.id }
        expect(response).to redirect_to root_path
      end
    end

    # ゲストとして
    context 'as a guest' do
      before do
        @other_user = create(:user)
      end

      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        delete :destroy, params: { id: @other_user.id }
        expect(response).to have_http_status '302'
      end

      # ログインへリダイレクトすること
      it 'redirects to login page' do
        delete :destroy, params: { id: @other_user.id }
        expect(response).to redirect_to login_path
      end

      # 投稿を削除できないこと
      it 'does not delete the post' do
        expect do
          delete :destroy, params: { id: @other_user.id }
        end.to_not change(User, :count)
      end
    end
  end
end
