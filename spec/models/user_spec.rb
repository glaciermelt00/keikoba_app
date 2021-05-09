require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user, name: 'Example User', email: 'user@example.com') }

  it 'expects valid' do
    expect(user.valid?).to true
  end
end
