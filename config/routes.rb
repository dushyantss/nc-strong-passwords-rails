Rails.application.routes.draw do
  root to: "users#index"

  post "/", to: "users#bulk_upload", as: :bulk_upload
end
