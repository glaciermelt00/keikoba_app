require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_length_of(:name).is_at_least(3).is_at_most(50) }
  it { is_expected.to validate_presence_of :email }

  valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
  valid_addresses.each do |valid_address|
    it { is_expected.to allow_value(valid_address).for(:email) } 
  end

  invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
  invalid_addresses.each do |invalid_address|
    it { is_expected.to_not allow_value(invalid_address).for(:email) } 
  end

  it { is_expected.to validate_length_of(:email).is_at_most(255) }
  it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
  it { is_expected.to have_secure_password :password }
  it { is_expected.to validate_presence_of(:password).allow_nil }
  it { is_expected.to validate_length_of(:password).is_at_least(6) }
  it { is_expected.to have_many(:posts).dependent(:destroy) }
  it { is_expected.to have_many(:favorites).dependent(:destroy) }
  it { is_expected.to have_many(:favorite_posts).through(:favorites).source(:post) }
  it { is_expected.to have_many(:bookmarks).dependent(:destroy) }
  it { is_expected.to have_many(:bookmark_posts).through(:bookmarks).source(:post) }

  # name, email, passwordがあれば、有効な状態であること
  it 'is valid with a name, email, and password' do
    expect(user).to be_valid
  end

  # DBに保存されたemailは小文字であること
  it 'makes email downcase when user is saved to DB' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    user.update_attribute(:email, mixed_case_email)
    expect(mixed_case_email.downcase).to eq user.email
  end

  # rememberメソッドを呼び出すと、remember_digestが上書きされる
  it 'updates remember_digest with remember method' do
    @user = create(:user, :do_remember)
    expect(@user.remember_digest).to_not be_nil
  end

  # digestが存在し、authenticated?メソッドに適切なtokenを渡すと、trueを返す
  it 'returns true with authenticated? method and appropriate token if digest is present' do
    @user = create(:user, :do_remember)
    expect(@user.authenticated?(:remember, @user.remember_token)).to be true
  end

  # digestがnilなら、authenticated?メソッドはfalseを返す
  it 'returns false with authenticated? method if digest is nil' do
    expect(user.authenticated?(:remember, '')).to be false
  end

  # forgetメソッドで、remember_digestがnilになる
  it 'updates remember_digest to nil with forget method' do
    @user = create(:user, :do_remember)
    @user.forget
    expect(@user.remember_digest).to be_nil
  end

  # activateメソッドで、activatedがtrueに上書きされる
  it 'updates activated to true with activate method' do
    @user = create(:user, :do_activate)
    expect(@user.activated).to be true
  end

  # activateメソッドで、activated_atが現在時刻に上書きされる
  it 'updates activated_at to present time with activate method' do
    @user = create(:user, :do_activate)
    expect(@user.activated_at).to_not be_nil
  end

  # create_reset_digestメソッドで、reset_digestが上書きされる
  it 'updates reset_digest with create_reset_digest method' do
    user.save
    user.create_reset_digest
    expect(user.reset_digest).to_not be_nil
  end

  # create_reset_digestメソッドで、reset_sent_atが上書きされる
  it 'updates reset_sent_at with create_reset_digest method' do
    user.save
    user.create_reset_digest
    expect(user.reset_sent_at).to_not be_nil
  end

  # reset_sent_atから2時間過ぎたら、password_reset_expired?メソッドはtrueを返す
  it 'returns true with password_reset_expired? method if it takes 2 hours from reset_sent_at' do
    user.save
    user.create_reset_digest
    user.reset_sent_at = 2.hours.ago
    expect(user.password_reset_expired?).to be true
  end

  # before_createで発生するprivateのcreate_activation_digestで、activation_tokenが作成される
  it 'creates activation_token with privated create_activation_digest method caused by before_create' do
    expect(user.activation_token).to be_nil
    user.save
    expect(user.activation_token).to_not be_nil
  end

  # before_createで発生するprivateのcreate_activation_digestで、activation_digestが作成される
  it 'creates activation_digest with privated create_activation_digest method caused by before_create' do
    expect(user.activation_digest).to be_nil
    user.save
    expect(user.activation_digest).to_not be_nil
  end
end
