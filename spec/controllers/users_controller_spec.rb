require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  # let(:user) { create(:user, :do_activate) }
  let(:user_params) { attributes_for(:user) }

  it { is_expected.to use_before_action :logged_in_user}
  it { is_expected.to use_before_action :correct_user}
  it { is_expected.to use_before_action :admin_user}
  it { is_expected.to permit(:name, :email, :password, :password_confirmation).for(:create, params: { user: user_params } ) }
  # it { is_expected.to permit(:name, :email, :password, :password_confirmation).for(:update, params: { id: user.id, user: user_params } ) }

  describe '#new' do
    # 正常にレスポンスを返すこと
    it 'responds successfully' do
      get :new
      aggregate_failures do
        expect(response).to be_successful
        expect(response).to have_http_status '200'
      end
    end
  end

  describe '#create' do
    # 有効な属性値の場合
    context 'with valid attributes' do
      # ユーザーを追加できること
      it 'adds a user' do
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
    # 正常にレスポンスを返すこと
    it 'responds successfully' do
      @user = create(:user, :do_activate)
      get :show, params: { id: @user.id }

      aggregate_failures do
        expect(response).to be_successful
        expect(response).to have_http_status '200'
      end
    end
  end

  describe '#index' do
    # 正常にレスポンスを返すこと
    it 'responds successfully' do
      @user = create(:user, :do_activate)
      get :index

      aggregate_failures do
        expect(response).to be_successful
        expect(response).to have_http_status '200'
      end
    end
  end

  describe '#edit' do
    # 認可されたユーザーとして
    context 'as an authorized user' do
      # 正常にレスポンスを返すこと
      it 'responds successfully' do
        @user = create(:user, :do_activate)
        log_in_as @user
        get :edit, params: { id: @user.id }
        expect(response).to be_successful
      end
    end

    # 認可されていないユーザーとして
    context 'as an unauthorized user' do
      # rootにリダイレクトすること
      it 'redirects to root' do
        @user = create(:user)
        @other_user = create(:user)
        log_in_as @user
        get :edit, params: { id: @other_user.id }
        expect(response).to redirect_to root_path
      end
    end

    # ゲストとして
    context 'as a guest' do
      # 302レスポンスを返し、dangerフラッシュメッセージが出力し、ログイン画面にリダイレクトすること
      it 'returns a 302 response & prints danger flash message & redirects to login page' do
        @other_user = create(:user)
        get :edit, params: { id: @other_user.id }

        aggregate_failures do
          expect(response).to have_http_status '302'
          expect(flash[:danger]).to eq 'ログインしてください'
          expect(response).to redirect_to login_path
        end
      end
    end
  end

  describe '#update' do
    # 認可されたユーザーとして
    context 'as an authorized user' do
      # ユーザー情報を更新できること
      it 'updates a post' do
        @user = create(:user)
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

      # 302レスポンスを返し、dangerフラッシュメッセージを出力し、ログイン画面にリダイレクトすること
      it 'returns a 302 response & prints danger flash message & redirects to login page' do
        patch :update, params: { id: @other_user.id, user: user_params }

        aggregate_failures do
          expect(response).to have_http_status '302'
          expect(flash[:danger]).to eq 'ログインしてください'
          expect(response).to redirect_to login_path
        end
      end
    end
  end

  describe '#destroy' do
    # 認可されたユーザーとして
    context 'as an authorized user' do
      # 投稿を削除できること
      it 'deletes a post' do
        @user = create(:user, admin: true)
        @other_user = create(:user)
        log_in_as @user

        expect do
          delete :destroy, params: { id: @other_user.id }
        end.to change(User, :count).by(-1)
      end
    end

    # 認可されていないユーザーとして
    context 'as an unauthorized user' do
      # 投稿を削除できず、rootへリダイレクトすること
      it 'does not delete the post & redirects to root' do
        @user = create(:user)
        @other_user = create(:user)
        log_in_as @user

        aggregate_failures do
          expect do
            delete :destroy, params: { id: @other_user.id }
          end.to_not change(User, :count)
          expect(response).to redirect_to root_path
        end
      end
    end

    # ゲストとして
    context 'as a guest' do
      # 投稿を削除できず、302レスポンスを返し、ログインへリダイレクトすること
      it 'does not delete a post & returns a 302 response & redirects to login page' do
        @other_user = create(:user)

        aggregate_failures do
          expect do
            delete :destroy, params: { id: @other_user.id }
          end.to_not change(User, :count)
          expect(response).to have_http_status '302'
          expect(response).to redirect_to login_path
        end
      end
    end
  end
end
