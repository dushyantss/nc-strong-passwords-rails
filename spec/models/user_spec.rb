require 'rails_helper'

RSpec.describe User, type: :model do

  context "validations" do
    it "requires a name" do
      user = User.new(name: nil)

      expect(user).to_not be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "requires a password" do
      user = User.new(password: nil)

      expect(user).to_not be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end
  end
end
