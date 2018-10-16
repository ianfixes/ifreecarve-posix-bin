#!/usr/bin/env ruby

require_relative "./organize_photos"

begin
  require 'exif'
rescue
  puts "You need to `gem install exif`"
end


# return regex for extracting "2013:12:08 21:14:11"
def image_date_extractor
  /(\d{4}):(\d{2}):(\d{2}) /i
end

class ExifStrategy < Strategy
  def exif_of_image(path)
    Exif::Data.new(File.open(path.to_s)) # load from file
  end

  def date_of_exif(exif)
    exif.date_time     # => "2013:12:08 21:14:11"
  end

  def image_of_interest?(path)
    exif = exif_of_image(path)
    return false unless exif
    !image_date_extractor.match(date_of_exif(exif)).nil?
  end

  def date_from_image(path)
    exif = exif_of_image(path)
    D8.of_a(image_date_extractor.match(date_of_exif(exif)).captures[0..2].map(&:to_i))
  end
end

organize(ExifStrategy.new)