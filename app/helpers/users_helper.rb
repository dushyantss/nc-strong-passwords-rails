module UsersHelper
  def user_upload_result(user)
    if user.errors.present?
      user.errors.full_messages.map {|message| message.gsub("Password ", "")}.join(", ")
    else
      t("helpers.users.user_successfully_created", name: user.name)
    end
  end
end
