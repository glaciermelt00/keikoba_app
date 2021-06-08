require 'rails_helper'

RSpec.describe FavoritesController, type: :controller do
  describe '#create' do
    # 認可されたユーザーとして
    context 'as an authorized user' do
      before do
        @user = create(:user)
        @post = create(:post, user: @user)
      end

      # favoriteを追加できること
      # it 'adds a favorite' do
      #   log_in_as @user
      #   fav_params = { user_id: @user.id, post_id: @post.id }
      #   expect do
      #     post :create, params: fav_params
      #   end.to change(Favorite, :count).by(1)
      # end
    end

    # 認可されていないユーザーとして
    context 'as an unauthorized user' do
      before do
        @user = create(:user)
        other_user = create(:user)
        @post = create(:post, user: other_user)
      end

      # favoriteを追加できないこと
      # it 'does not adda a favorite' do

      # end

      # rootにリダイレクトすること
      # it 'redirects to root' do

      # end
    end

    # ゲストとして
    context 'as a guest' do
      before do
        other_user = create(:user)
        @post = create(:post, user: other_user)
      end

      # loginページにリダイレクトすること
      # it 'redirects to login page' do

      # end
    end
  end

  describe '#destroy' do
  end
end
