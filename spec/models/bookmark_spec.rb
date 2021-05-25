require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  before(:each) do
    @user = FactoryBot.create(:user)
    @another_user = FactoryBot.create(:another_user)
    @post = FactoryBot.create(:post)
    @bookmark = Bookmark.new(user_id: @another_user.id, post_id: @post.id)
  end

  it 'bookmarkが有効である' do
    expect(@bookmark).to be_valid
  end

  it 'bookmarkにはuser_idが必要' do
    @bookmark.user_id = nil
    expect(@bookmark).not_to be_valid
  end

  it 'bookmarkにはpost_idが必要' do
    @bookmark.post_id = nil
    expect(@bookmark).not_to be_valid
  end

  it 'user_idとpost_idの組み合わせは一意である' do
    duplicate_bookmark = @bookmark.dup
    @bookmark.save
    expect(duplicate_bookmark).not_to be_valid
  end
end
