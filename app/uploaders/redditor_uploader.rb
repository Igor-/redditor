# encoding: utf-8

class RedditorUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :admin do
    # process :resize_to_fit => [119, 119]
    process :resize_and_pad => [119, 119, :transparent, ::Magick::CenterGravity]
  end

  version :show do
    process :resize_to_fill => [960, 640], :if => :is_slider?
    process :resize_to_limit => [960, 3000], :if => :is_image?
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end


  # Для того чтобы можно было использовать эти методы ввиде условий необходимо,
  # чтобы изображение сохранялось через update_attributes вместо save
  def is_slider? picture
    model.imageable_type == "Redditor::SliderBlock"
  end

  def is_image? picture
    model.imageable_type == "Redditor::Page"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
