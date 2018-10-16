#!/usr/bin/env ruby

require_relative "./organize_photos"

# return regex for IMG_20180203_12345667.jpg
def image_date_extractor
  /[^_]+_(\d{4})(\d{2})(\d{2})_([\d_~]+)\./i
end


class FilenameStrategy < Strategy
  def image_of_interest?(path)
    !image_date_extractor.match(path.basename.to_s).nil?
  end

  def date_from_image(path)
    D8.of_a(image_date_extractor.match(path.basename.to_s).captures[0..2].map(&:to_i))
  end
end

organize(FilenameStrategy.new)