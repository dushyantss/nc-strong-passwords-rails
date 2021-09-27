require 'rails_helper'

VALID_NAME = "Dushyant"
VALID_PASSWORD = "ABCdef1234"

RSpec.describe UsersHelper, type: :helper do
  describe "#user_upload_result" do
    it "shows name error if it exists" do
      u = User.create(name: nil, password: VALID_PASSWORD)

      expect(helper.user_upload_result(u)).to eq("Name can't be blank")
    end

    it "shows password error if it exists" do
      u = User.create(name: VALID_NAME, password: nil)

      expect(helper.user_upload_result(u)).to eq("Change 10 characters of #{VALID_NAME}'s password")
    end

    it "shows both name and password error if both exist" do
      u = User.create(name: nil, password: nil)

      expect(helper.user_upload_result(u)).to eq("Name can't be blank, Change 10 characters of User's password")
    end

    it "shows success message if no error exists" do
      u = User.create(name: VALID_NAME, password: VALID_PASSWORD)

      expect(helper.user_upload_result(u)).to eq("#{VALID_NAME} was successfully saved")
    end
  end
end
