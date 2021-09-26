require 'rails_helper'

RSpec.describe User, type: :model do

  it "has a valid factory" do
    user = build(:user)

    expect(user).to be_valid
  end

  context "validations" do
    it "requires a name" do
      user = build(:user, name: nil)

      expect(user).to_not be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "requires a password" do
      user = build(:user, password: nil)

      expect(user).to_not be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end
  end
end
