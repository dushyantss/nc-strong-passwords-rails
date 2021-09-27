require 'rails_helper'

RSpec.describe "UploadUsersCsvOnHomePages", type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario "successfully" do
    visit root_path

    attach_file :file, 'spec/fixtures/users.csv'

    click_on "Submit"

    expect(page).to have_selector("li", text: 'Muhammad was successfully saved')
    expect(page).to have_selector("li", text: "Change 1 character of Maria Turing's password")
    expect(page).to have_selector("li", text: "Change 4 characters of Isabella's password")
    expect(page).to have_selector("li", text: "Change 5 characters of Axel's password")
  end
end
