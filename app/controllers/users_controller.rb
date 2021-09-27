class UsersController < ApplicationController
  def index
    @results = []
  end

  def bulk_upload
    @results = []
    CSV.foreach(bulk_upload_file.path, headers: true) do |row|
      @results << User.create(row)
    end

    render :index
  end

  def bulk_upload_file
    params.require(:file)
  end
end
