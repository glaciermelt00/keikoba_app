require 'rails_helper'

RSpec.describe Favorite, type: :model do
  before(:each) do
    @user = FactoryBot.create(:user)
    @another_user = FactoryBot.create(:another_user)
    @post = FactoryBot.create(:post)
    @favorite = Favorite.new(user_id: @another_user.id, post_id: @post.id)
  end

  it 'favoriteが有効である' do
    expect(@favorite).to be_valid
  end

  it 'favoriteにはuser_idが必要' do
    @favorite.user_id = nil
    expect(@favorite).not_to be_valid
  end

  it 'favoriteにはpost_idが必要' do
    @favorite.post_id = nil
    expect(@favorite).not_to be_valid
  end

  it 'user_idとpost_idの組み合わせは一意である' do
    duplicate_favorite = @favorite.dup
    @favorite.save
    expect(duplicate_favorite).not_to be_valid
  end
end
