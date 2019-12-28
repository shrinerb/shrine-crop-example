require "./config/shrine"
require "image_processing/vips"

class ImageUploader < Shrine
  MAX_SIZE       = 10*1024*1024
  ALLOWED_EXTS   = %w[jpg jpeg png webp]
  ALLOWED_TYPES  = %w[image/jpeg image/png image/webp]
  MAX_DIMENSIONS = [5000, 5000]

  plugin :store_dimensions, analyzer: :fastimage
  plugin :derivation_endpoint, prefix: "derivations/image"

  THUMBNAILS = {
    large:  [800, 800],
    medium: [600, 600],
    small:  [300, 300],
  }

  Attacher.validate do
    validate_max_size MAX_SIZE
    validate_extension ALLOWED_EXTS
    if validate_mime_type ALLOWED_TYPES
      validate_max_dimensions MAX_DIMENSIONS
    end
  end

  # Crops original and generates thumbnails from the cropped image.
  Attacher.derivatives do |original|
    result =      process_derivatives(:cropped,    original)
    result.merge! process_derivatives(:thumbnails, result[:cropped])
  end

  # Generates a cropped image.
  Attacher.derivatives :cropped do |original|
    vips        = ImageProcessing::Vips.source(original)
    crop_points = file["crop"].fetch_values("x", "y", "width", "height")

    { cropped: vips.crop!(*crop_points) }
  end

  # Generates a set of thumbnails.
  Attacher.derivatives :thumbnails do |original|
    vips = ImageProcessing::Vips.source(original)

    THUMBNAILS.inject({}) do |result, (name, (width, height))|
      result.merge! name => vips.resize_to_limit!(width, height)
    end
  end

  # Default URLs of missing derivatives to on-the-fly processing.
  Attacher.default_url do |derivative: nil, **|
    next unless derivative && file

    transformations = {}

    if THUMBNAILS.key?(derivative) || derivative == :cropped
      transformations[:crop] = file["crop"].fetch_values("x", "y", "width", "height")
    end

    if THUMBNAILS.key?(derivative)
      transformations[:resize_to_limit] = THUMBNAILS.fetch(derivative)
    end

    file.derivation_url(:transform, shrine_class.urlsafe_serialize(transformations))
  end

  # Generic derivation that applies a given sequence of transformations.
  derivation :transform do |file, transformations|
    transformations = shrine_class.urlsafe_deserialize(transformations)

    vips = ImageProcessing::Vips.source(file)
    vips.apply!(transformations)
  end
end
