require 'rails_helper'

RSpec.describe Post, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to have_many(:favorites).dependent(:destroy) }
  it { is_expected.to have_many(:bookmarks).dependent(:destroy) }
  it { is_expected.to have_many_attached :images }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :user_id }

  # name, user_idがあれば、有効な状態であること
  it 'is valid with a name and user_id' do
    @post = create(:post)
    expect(@post).to be_valid
  end

  # postはcreated_atの降順で並んでいる
  it 'is sorted in descending order by created_at' do
    @most_recent_post = create(:most_recent_post)
    create_list(:post, 3)
    expect(@most_recent_post).to eq Post.first
  end
end
