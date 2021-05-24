require 'rails_helper'

RSpec.describe User, type: :model do
  it 'userは有効である' do
    user = FactoryBot.build(:user)
    expect(user).to be_valid
  end

  describe 'nameについて' do
    it '存在する' do
      user = FactoryBot.build(:user, name: '   ')
      expect(user).not_to be_valid
    end

    it '3~50文字の範囲内である' do
      user = FactoryBot.build(:user, name: 'a' * 2)
      expect(user).not_to be_valid
      user.name = 'a' * 51
      expect(user).not_to be_valid
    end
  end

  describe 'emailについて' do
    it '存在する' do
      user = FactoryBot.build(:user, email: '   ')
      expect(user).not_to be_valid
    end

    it '255文字以内である' do
      user = FactoryBot.build(:user, email: format('%s@example.com', ('a' * 244)))
      expect(user).not_to be_valid
    end

    it 'フォーマットに合致するものは通す' do
      user = FactoryBot.build(:user)
      valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
      valid_addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid
      end
    end

    it 'フォーマットに合致しないものは通さない' do
      user = FactoryBot.build(:user)
      invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      invalid_addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).not_to be_valid
      end
    end

    it '一意である' do
      user = FactoryBot.build(:user)
      duplicate_user = user.dup
      user.save
      expect(duplicate_user).not_to be_valid
    end

    it 'DBに保存されたものは小文字である' do
      mixed_case_email = 'Foo@ExAMPle.CoM'
      user = FactoryBot.build(:user, email: mixed_case_email)
      user.save
      expect(mixed_case_email.downcase).to eq user.reload.email
    end
  end

  describe 'パスワードについて' do
    it '存在する' do
      user = FactoryBot.build(:user)
      user.password = user.password_confirmation = ' ' * 6
      expect(user).not_to be_valid
    end

    it '6文字以上である' do
      user = FactoryBot.build(:user)
      user.password = user.password_confirmation = 'a' * 5
      expect(user).not_to be_valid
    end
  end

  describe 'digestがnilの場合' do
    it 'authenticated?メソッドはfalseを返す' do
      user = FactoryBot.build(:user)
      expect(user.authenticated?(:remember, '')).to be false
    end
  end

  describe 'userが削除された場合' do
    it '関連付けられたpostが削除される' do
      user = FactoryBot.build(:user)
      user.save
      user.posts.create!(name: 'Lorem ipsum')
      expect { user.destroy }.to change { Post.count }.from(1).to(0)
    end

    it '関連付けられたBookmark_postが削除される' do
      user = FactoryBot.build(:user)
      another_user = FactoryBot.build(:another_user)
      user.save
      another_user.save
      post = user.posts.create!(name: 'Lorem ipsum')
      Bookmark.create!(user_id: another_user.id, post_id: post.id)
      expect { user.destroy }.to change { Bookmark.count }.from(1).to(0)
    end

    it '関連付けられたbookmark_postが削除される' do
      user = FactoryBot.build(:user)
      another_user = FactoryBot.build(:another_user)
      user.save
      another_user.save
      post = user.posts.create!(name: 'Lorem ipsum')
      Bookmark.create!(user_id: another_user.id, post_id: post.id)
      expect { user.destroy }.to change { Bookmark.count }.from(1).to(0)
    end
  end
end
