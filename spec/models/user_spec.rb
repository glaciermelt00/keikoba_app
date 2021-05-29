require 'rails_helper'

RSpec.describe User, type: :model do
  before(:each) do
    @user = build(:user)
  end

  # name, email, passwordがあれば、有効な状態であること
  it 'is valid with a name, email, and password' do
    expect(@user).to be_valid
  end

  describe 'name' do
    # nameが空白なら、無効な状態であること
    it 'is invalid with a blank name' do
      @user.name = '   '
      @user.valid?
      expect(@user.errors[:name]).to include("を入力してください")
    end

    # nameが3文字未満なら、無効な状態であること
    it 'is invalid with a name less than 3 characters' do
      @user.name = 'a' * 2
      @user.valid?
      expect(@user.errors[:name]).to include("は3文字以上で入力してください")
    end

    # nameが50文字を超えるなら、無効な状態であること
    it 'is invalid for a name more than 50 characters' do
      @user.name = 'a' * 51
      @user.valid?
      expect(@user.errors[:name]).to include("は50文字以内で入力してください")
    end
  end

  describe 'email' do
    # emailが空白なら、無効な状態であること
    it 'is invalid with a blank email' do
      @user.email = '   '
      @user.valid?
      expect(@user.errors[:email]).to include("を入力してください")
    end

    # emailが255文字を超えると、無効な状態であること
    it 'is invalid for a email more than 255 characters' do
      @user.email = format('%s@example.com', ('a' * 244))
      @user.valid?
      expect(@user.errors[:email]).to include("は255文字以内で入力してください")
    end

    # フォーマットに合致するemailなら、有効な状態であること
    it 'is valid with an email that matches the format ' do
      valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
      valid_addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end

    # フォーマットに合致しないemailなら、無効な状態であること
    it 'is invalid with an email that does not match the format' do
      invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      invalid_addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.valid?
        expect(@user.errors[:email]).to include("は不正な値です")
      end
    end

    # 重複したemailなら、無効な状態であること
    it 'is invalid with a duplicate email ' do
      duplicate_user = @user.dup
      @user.save
      duplicate_user.valid?
      expect(duplicate_user.errors[:email]).to include("はすでに存在します")
    end

    # DBに保存されたemailは小文字であること
    it 'makes email downcase when user is saved to DB' do
      mixed_case_email = 'Foo@ExAMPle.CoM'
      @user.email = mixed_case_email
      @user.save
      expect(mixed_case_email.downcase).to eq @user.reload.email
    end
  end

  # passwordが空白なら、無効な状態であること
  it 'is invalid with a blank password' do
    @user.password = @user.password_confirmation = ' ' * 6
    @user.valid?
    expect(@user.errors[:password]).to include("を入力してください")
  end

  # passwordが6文字未満なら、無効な状態であること
  it 'is invalid for a password less than 6 characters' do
    @user.password = @user.password_confirmation = 'a' * 5
    @user.valid?
    expect(@user.errors[:password]).to include("は6文字以上で入力してください")
  end

  # rememberメソッドを呼び出すと、remember_digestが上書きされる
  it 'updates remember_digest with remember method' do
    @user.save
    expect(@user.remember_digest).to be_nil
    @user.remember
    expect(@user.remember_digest).to_not be_nil
  end

  # digestが存在し、authenticated?メソッドに適切なtokenを渡すと、trueを返す
  it 'returns true with authenticated? method and appropriate token if digest is present' do
    @user.save
    @user.remember
    expect(@user.authenticated?(:remember, @user.remember_token)).to be true
  end

  # digestがnilなら、authenticated?メソッドはfalseを返す
  it 'returns false with authenticated? method if digest is nil' do
    expect(@user.authenticated?(:remember, '')).to be false
  end

  # forgetメソッドで、remember_digestがnilになる
  it 'updates remember_digest to nil with forget method' do
    @user.save
    @user.remember
    expect(@user.remember_digest).to_not be_nil
    @user.forget
    expect(@user.remember_digest).to be_nil
  end

  # activateメソッドで、activatedがtrueに上書きされる
  it 'updates activated to true with activate method' do
    @user.save
    @user.toggle!(:activated)
    expect(@user.activated).to be false
    @user.activate
    expect(@user.activated).to be true
  end

  # activateメソッドで、activated_atが現在時刻に上書きされる
  it 'updates activated_at to present time with activate method' do
    @user.save
    @user.activated_at = nil
    expect(@user.activated_at).to be_nil
    @user.activate
    expect(@user.activated_at).to_not be_nil
  end

  # create_reset_digestメソッドで、reset_digestが上書きされる
  it 'updates reset_digest with create_reset_digest method' do
    @user.save
    expect(@user.reset_digest).to be_nil
    @user.create_reset_digest
    expect(@user.reset_digest).to_not be_nil
  end

  # create_reset_digestメソッドで、reset_sent_atが上書きされる
  it 'updates reset_sent_at with create_reset_digest method' do
    @user.save
    expect(@user.reset_sent_at).to be_nil
    @user.create_reset_digest
    expect(@user.reset_sent_at).to_not be_nil
  end

  # reset_sent_atから2時間過ぎたら、password_reset_expired?メソッドはtrueを返す
  it 'returns true with password_reset_expired? method if it takes 2 hours from reset_sent_at' do
    @user.save
    @user.create_reset_digest
    @user.reset_sent_at = 2.hours.ago
    expect(@user.password_reset_expired?).to be true
  end

  # before_createで発生するprivateのcreate_activation_digestで、activation_tokenが作成される
  it 'creates activation_token with privated create_activation_digest method caused by before_create' do
    expect(@user.activation_token).to be_nil
    @user.save
    expect(@user.activation_token).to_not be_nil
  end

  # before_createで発生するprivateのcreate_activation_digestで、activation_digestが作成される
  it 'creates activation_digest with privated create_activation_digest method caused by before_create' do
    expect(@user.activation_digest).to be_nil
    @user.save
    expect(@user.activation_digest).to_not be_nil
  end

  # userが削除された場合
  describe 'if user is deleted' do
    before do
      @user.save
      @another_user = FactoryBot.create(:another_user)
      @post = @user.posts.create!(name: 'Lorem ipsum')
    end

    # 関連付けられたpostが削除される
    it 'associated post is deleted' do
      expect { @user.destroy }.to change { Post.count }.from(1).to(0)
    end

    # 関連付けられたFavorite_postが削除される
    it 'associated favorite_post is deleted' do
      Favorite.create!(user_id: @another_user.id, post_id: @post.id)
      expect { @user.destroy }.to change { Favorite.count }.from(1).to(0)
    end

    # 関連付けられたbookmark_postが削除される
    it 'associated bookmark_post is deleted' do
      Bookmark.create!(user_id: @another_user.id, post_id: @post.id)
      expect { @user.destroy }.to change { Bookmark.count }.from(1).to(0)
    end
  end
end
