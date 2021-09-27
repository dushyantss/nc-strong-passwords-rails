require 'rails_helper'

RSpec.describe UsersBulkUploader do
  it "discards empty file" do
    results = UsersBulkUploader.new(nil).call

    expect(results).to eq([])
  end

  it "opens valid file and uploads users" do
    results = UsersBulkUploader.new(File.open("spec/fixtures/users.csv")).call

    expect(results.size).to eq(4)
    expect(results.first.id).to_not eq(nil)
    expect(results[1..].map(&:id)).to eq([nil,nil,nil])
  end
end