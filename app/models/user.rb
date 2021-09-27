class User < ApplicationRecord

  validates :name, presence: true
  validate :password_should_be_strong

  private

  def password_should_be_strong
    count = StrongPasswordCharacterChangeCounter.new(password).call
    if count > 0
      errors.add(:password, :change_count_for_strong_password, name: name || "User", count: count)
    end
  end
end
