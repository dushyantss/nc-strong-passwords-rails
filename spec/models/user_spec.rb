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

    it "Uses strong password validation instead of presence check for empty password" do
      user = build(:user, password: nil)

      expect(user).to_not be_valid
      expect(user.errors[:password]).to_not include("can't be blank")
    end

    it "should accept a strong password" do
      strong_passwords = [
        "Aqpfk1swods",
        "QPFJWz1343439",
        "PFsHH78KSM", # Test case in problem statement is incorrect
        "AAaaBBbbCCcc11@-",
        "abcdefghijklmnO9",
        "0123456789ABCDEf",
        "00112233Aa"
      ]

      strong_passwords.each do |password|
        user = build(:user, password: password)
        
        expect(user).to be_valid, "expected strong_password '#{password}' to be valid"
      end
    end

    it "should raise an error for weak passwords" do
      weak_passwords = [
        ["Abc123", 4],
        ["abcdefghijklmnop", 2],
        ["AAAfk1swods", 1],
        ["0123456789AABBCCdd", 2],
        ["000aaaBBBccccDDD", 5]
      ]

      weak_passwords.each do |password, change_count|
        user = build(:user, password: password)
        
        expect(user).to_not be_valid, "expected weak password '#{password}' to not be valid"
        expect(user.errors[:password]).to(
          include("Change #{change_count} character#{'s' if change_count > 1} of #{user.name}'s password"),
          "expected weak password '#{password}'' to require #{change_count} changes"
        )
      end
    end
  end
end
