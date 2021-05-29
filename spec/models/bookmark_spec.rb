require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  before(:each) do
    @user = FactoryBot.create(:user)
    @another_user = FactoryBot.create(:another_user)
    @post = FactoryBot.create(:post)
    @bookmark = Bookmark.new(user_id: @another_user.id, post_id: @post.id)
  end

  # post_id, user_idがあれば、有効な状態であること
  it 'is valid with post_id and user_id' do
    expect(@bookmark).to be_valid
  end

  # user_idがnilなら、無効な状態であること
  it 'is invalid without user_id' do
    @bookmark.user_id = nil
    @bookmark.valid?
    expect(@bookmark.errors[:user_id]).to include("を入力してください")
  end

  # post_idがnilなら、無効な状態であること
  it 'is invalid without post_id' do
    @bookmark.post_id = nil
    @bookmark.valid?
    expect(@bookmark.errors[:post_id]).to include("を入力してください")
  end

  # 重複したbookmarkなら、無効な状態であること
  it 'is invalid with a duplicate bookmark' do
    duplicate_bookmark = @bookmark.dup
    @bookmark.save
    duplicate_bookmark.valid?
    expect(duplicate_bookmark.errors[:post_id]).to include("はすでに存在します")  end
end
