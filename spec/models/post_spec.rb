require 'rails_helper'

RSpec.describe Post, type: :model do
  before(:each) do
    @user = FactoryBot.create(:user)
    @post = FactoryBot.build(:post)
  end

  # name, user_idがあれば、有効な状態であること
  it 'is valid with a name and user_id' do
    expect(@post).to be_valid
  end

  # user_idがnilなら、無効な状態であること
  it 'is invalid without user_id' do
    @post.user_id = nil
    @post.valid?
    expect(@post.errors[:user_id]).to include("を入力してください")
  end

  # nameが空白なら、無効な状態であること
  it 'is invalid with a blank name' do
    @post.name = ' '
    @post.valid?
    expect(@post.errors[:name]).to include("を入力してください")
  end

  # postはcreated_atの降順で並んでいる
  it 'is sorted in descending order by created_at' do
    @most_recent_post = FactoryBot.create(:most_recent_post)
    FactoryBot.create_list(:post, 3)
    expect(@most_recent_post).to eq Post.first
  end

  # postが削除されたとき
  context 'if post is deleted' do
    before do
      @another_user = FactoryBot.create(:another_user)
      @post.save
    end
    # 関連付けられたFavoriteが削除される
    it 'associated favorite is deleted' do
      Favorite.create!(user_id: @another_user.id, post_id: @post.id)
      expect { @post.destroy }.to change { Favorite.count }.from(1).to(0)
    end

    # 関連付けられたBookmarkが削除される
    it 'associated bookmark is deleted' do
      Bookmark.create!(user_id: @another_user.id, post_id: @post.id)
      expect { @post.destroy }.to change { Bookmark.count }.from(1).to(0)
    end
  end
end
