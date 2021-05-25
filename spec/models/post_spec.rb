require 'rails_helper'

RSpec.describe Post, type: :model do
  before(:each) do
    @user = FactoryBot.create(:user)
    @post = FactoryBot.build(:post)
  end

  it 'postは有効である' do
    expect(@post).to be_valid
  end

  it 'postのuser_idは存在する' do
    @post.user_id = nil
    expect(@post).not_to be_valid
  end

  it 'postのnameは存在する' do
    @post.name = ' '
    expect(@post).not_to be_valid
  end

  context '複数のpostが保存された場合' do
    before do 
      @most_recent_post = FactoryBot.create(:most_recent_post)
      FactoryBot.create_list(:post, 3)
    end
    it 'postは降順で並んでいる' do
      expect(@most_recent_post).to eq Post.first
    end
  end

  context 'postが削除された場合' do
    before do
      @another_user = FactoryBot.create(:another_user)
      @post.save
    end
    it '関連付けられたFavoriteが削除される' do
      Favorite.create!(user_id: @another_user.id, post_id: @post.id)
      expect { @post.destroy }.to change { Favorite.count }.from(1).to(0)
    end

    it '関連付けられたBookmarkが削除される' do
      Bookmark.create!(user_id: @another_user.id, post_id: @post.id)
      expect { @post.destroy }.to change { Bookmark.count }.from(1).to(0)
    end
  end
end
