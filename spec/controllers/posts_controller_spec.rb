require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  describe '#new' do
    # 認証済みのユーザーとして
    context 'as an authenticated user' do
      before do
        @user = create(:user)
      end

      # 正常にレスポンスを返すこと
      it 'responds successfully' do
        log_in_as @user
        get :new
        expect(response).to be_successful
      end

      # 200レスポンスを返すこと
      it 'returns a 200 response' do
        log_in_as @user
        get :new
        expect(response).to have_http_status '200'
      end
    end

    # ゲストとして
    context 'as a guest' do
      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        get :new
        expect(response).to have_http_status '302'
      end

      # ログイン画面にリダイレクトすること
      it 'redirects to the login page' do
        get :new
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#create' do
    # 認証済みのユーザーとして
    context 'as an authenticated user' do
      before do
        @user = create(:user)
      end

      # 有効な属性値の場合
      context 'with valid attributes' do
        # 投稿を追加できること
        it 'adds a post' do
          post_params = attributes_for(:post)
          log_in_as @user
          expect do
            post :create, params: { post: post_params }
          end.to change(@user.posts, :count).by(1)
        end
      end

      # 無効な属性値の場合
      context 'with invalid attributes' do
        # 投稿を追加できないこと
        it 'does not add a post' do
          post_params = attributes_for(:post, :invalid)
          log_in_as @user
          expect do
            post :create, params: { post: post_params }
          end.to_not change(@user.posts, :count)
        end
      end
    end

    # ゲストとして
    context 'as a guest' do
      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        post_params = attributes_for(:post)
        post :create, params: { post: post_params }
        expect(response).to have_http_status '302'
      end

      # ログイン画面にリダイレクトすること
      it 'redirects to the login page' do
        post_params = attributes_for(:post)
        post :create, params: { post: post_params }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#edit' do
    # 認可されたユーザーとして
    context 'as an authorized user' do
      before do
        @user = create(:user)
        @post = create(:post, user: @user)
      end

      # 正常にレスポンスを返すこと
      it 'responds successfully' do
        log_in_as @user
        get :edit, params: { id: @post.id }
        expect(response).to be_successful
      end
    end

    # 認可されていないユーザーとして
    context 'as an unauthorized user' do
      before do
        @user = create(:user)
        other_user = create(:user)
        @post = create(:post, user: other_user)
      end

      # rootにリダイレクトすること
      it 'redirects to root' do
        log_in_as @user
        get :edit, params: { id: @post.id }
        expect(response).to redirect_to root_path
      end
    end

    # ゲストとして
    context 'as a guest' do
      before do
        @post = create(:post)
      end

      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        get :edit, params: { id: @post.id }
        expect(response).to have_http_status '302'
      end

      # ログイン画面にリダイレクトすること
      it 'redirects to the login page' do
        get :edit, params: { id: @post.id }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#update' do
    # 認可されたユーザーとして
    context 'as an authorized user' do
      before do
        @user = create(:user)
        @post = create(:post, user: @user)
      end

      # 投稿を更新できること
      it 'updates a post' do
        post_params = attributes_for(:post, name: 'New Post Name')
        log_in_as @user
        patch :update, params: { id: @post.id, post: post_params }
        expect(@post.reload.name).to eq 'New Post Name'
      end
    end

    # 認可されていないユーザーとして
    context 'as an unauthorized user' do
      before do
        @user = create(:user)
        other_user = create(:user)
        @post = create(:post, user: other_user, name: 'Same Old Name')
      end

      # 投稿を更新できないこと
      it 'does not update the post' do
        post_params = attributes_for(:post, name: 'New Name')
        log_in_as @user
        patch :update, params: { id: @post.id, post: post_params }
        expect(@post.reload.name).to eq 'Same Old Name'
      end

      # rootへリダイレクトすること
      it 'redirects to root' do
        post_params = attributes_for(:post)
        log_in_as @user
        patch :update, params: { id: @post.id, post: post_params }
        expect(response).to redirect_to root_path
      end
    end

    # ゲストとして
    context 'as a guest' do
      before do
        @post = create(:post)
      end

      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        post_params = attributes_for(:post)
        patch :update, params: { id: @post.id, post: post_params }
        expect(response).to have_http_status '302'
      end

      # ログイン画面にリダイレクトすること
      it 'redirects to the login page' do
        post_params = attributes_for(:post)
        patch :update, params: { id: @post.id, post: post_params }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#destroy' do
    # 認可されたユーザーとして
    context 'as an authorized user' do
      before do
        @user = create(:user)
        @post = create(:post, user: @user)
      end

      # 投稿を削除できること
      it 'deletes a post' do
        log_in_as @user
        expect do
          delete :destroy, params: { id: @post.id }
        end.to change(@user.posts, :count).by(-1)
      end
    end

    # 認可されていないユーザーとして
    context 'as an unauthorized user' do
      before do
        @user = create(:user)
        other_user = create(:user)
        @post = create(:post, user: other_user)
      end

      # 投稿を削除できないこと
      it 'does not delete the post' do
        log_in_as @user
        expect do
          delete :destroy, params: { id: @post.id }
        end.to_not change(Post, :count)
      end

      # rootへリダイレクトすること
      it 'redirects to root' do
        log_in_as @user
        delete :destroy, params: { id: @post.id }
        expect(response).to redirect_to root_path
      end
    end

    # ゲストとして
    context 'as a guest' do
      before do
        @post = create(:post)
      end

      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        delete :destroy, params: { id: @post.id }
        expect(response).to have_http_status '302'
      end

      # ログインへリダイレクトすること
      it 'redirects to login page' do
        delete :destroy, params: { id: @post.id }
        expect(response).to redirect_to login_path
      end

      # 投稿を削除できないこと
      it 'does not delete the post' do
        expect do
          delete :destroy, params: { id: @post.id }
        end.to_not change(Post, :count)
      end
    end
  end
end
