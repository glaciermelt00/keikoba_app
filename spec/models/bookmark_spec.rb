require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :post }
  it { is_expected.to validate_presence_of :user_id }
  it { is_expected.to validate_presence_of :post_id }

  before(:each) do
    @post = create(:post)
    @another_user = create(:user)
    @bookmark = Bookmark.new(user_id: @another_user.id, post_id: @post.id)
  end

  # post_id, user_idがあれば、有効な状態であること
  it 'is valid with post_id and user_id' do
    expect(@bookmark).to be_valid
  end

  # 重複したbookmarkなら、無効な状態であること
  it 'is invalid with a duplicate bookmark' do
    duplicate_bookmark = @bookmark.dup
    @bookmark.save
    duplicate_bookmark.valid?
    expect(duplicate_bookmark.errors[:post_id]).to include('はすでに存在します')
  end
end
