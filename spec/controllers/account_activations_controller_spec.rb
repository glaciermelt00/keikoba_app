require 'rails_helper'

RSpec.describe AccountActivationsController, type: :controller do
  describe '#edit' do
    # 適切なユーザーとして
    context 'as a correct user' do
      before do
        @user = create(:user)
      end

      # successフラッシュメッセージが出力されること
      it 'prints success flash message' do
        activation_params = { id: @user.activation_token, email: @user.email }
        get :edit, params: activation_params
        expect(flash[:success]).to eq 'アカウントが有効になりました！'
      end

      # userページにリダイレクトすること
      it 'redirects to user page' do
        activation_params = { id: @user.activation_token, email: @user.email }
        get :edit, params: activation_params
        expect(response).to redirect_to user_path(@user.id)
      end
    end

    # 適切でないユーザーとして
    context 'as an uncorrect user' do
      # rootにリダイレクトすること
      it 'redirects to root' do
        activation_params = { id: '', email: '' }
        get :edit, params: activation_params
        expect(response).to redirect_to root_path
      end
    end
  end
end
