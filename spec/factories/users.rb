FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User#{n}" }
    sequence(:password) { |n| "Password0#{n}" }
  end
end
