class UsersBulkUploader
  def initialize(file)
    if file.present?
      @file_path = file.path
    else
      @file_path = nil
    end
  end

  def call
    results = []
    if @file_path.present?
      CSV.foreach(@file_path, headers: true) do |row|
        results << User.create(row)
      end
    end
    results
  end
end