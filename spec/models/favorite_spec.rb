require 'rails_helper'

RSpec.describe Favorite, type: :model do
  before(:each) do
    @post = create(:post)
    @another_user = create(:user)
    @favorite = Favorite.new(user_id: @another_user.id, post_id: @post.id)
  end

  # post_id, user_idがあれば、有効な状態であること
  it 'is valid with post_id and user_id' do
    expect(@favorite).to be_valid
  end

  # user_idがnilなら、無効な状態であること
  it 'is invalid without user_id' do
    @favorite.user_id = nil
    @favorite.valid?
    expect(@favorite.errors[:user_id]).to include('を入力してください')
  end

  # post_idがnilなら、無効な状態であること
  it 'is invalid without post_id' do
    @favorite.post_id = nil
    @favorite.valid?
    expect(@favorite.errors[:post_id]).to include('を入力してください')
  end

  # 重複したfavoriteなら、無効な状態であること
  it 'is invalid with a duplicate favorite' do
    duplicate_favorite = @favorite.dup
    @favorite.save
    duplicate_favorite.valid?
    expect(duplicate_favorite.errors[:post_id]).to include('はすでに存在します')
  end
end
