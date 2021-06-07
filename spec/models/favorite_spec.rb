require 'rails_helper'

RSpec.describe Favorite, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :post }
  it { is_expected.to validate_presence_of :user_id }
  it { is_expected.to validate_presence_of :post_id }

  before(:each) do
    @post = create(:post)
    @another_user = create(:user)
    @favorite = Favorite.new(user_id: @another_user.id, post_id: @post.id)
  end

  # post_id, user_idがあれば、有効な状態であること
  it 'is valid with post_id and user_id' do
    expect(@favorite).to be_valid
  end

  # 重複したfavoriteなら、無効な状態であること
  it 'is invalid with a duplicate favorite' do
    duplicate_favorite = @favorite.dup
    @favorite.save
    duplicate_favorite.valid?
    expect(duplicate_favorite.errors[:post_id]).to include('はすでに存在します')
  end
end
