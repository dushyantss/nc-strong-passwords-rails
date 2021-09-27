class UsersController < ApplicationController
  def index
    @results = []
  end

  def bulk_upload
    @results = UsersBulkUploader.new(bulk_upload_file).call
    render :index
  end

  def bulk_upload_file
    params.require(:file)
  end
end
