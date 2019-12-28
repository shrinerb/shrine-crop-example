require "./config/sequel"
require "./uploaders/image_uploader"

class Photo < Sequel::Model
  include ImageUploader::Attachment[:image]

  def validate
    validates_presence [:image, :title]
  end
end
