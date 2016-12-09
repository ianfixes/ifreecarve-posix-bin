#!/usr/bin/env ruby

require 'tmpdir'

def cmd(args)
  puts "running: #{args}"
  ret = `#{args}`
  puts ret
  ret
end

def dimensions(img_path)
  info = `identify "#{img_path}"`
  fields = info.split(" ")
  fields[2].split("x").map(&:to_i)
end

class Zoomer

  def initialize(img_path)
    @img_path = img_path
    @w0, @h0 = dimensions(@img_path)
  end

  # imagemagick dimensions
  def _dim(w, h, scale = 1)
    "#{(w * scale).round}x#{(h * scale).round}"
  end

  # imagemagick offset
  def _off(x, y)
    [x, y].map { |a| format("%+0d", a.round) }.join
  end

  # a piece of the render command. generates a snippet in the form:
  # \( "ab.png" -resize 155x302 \) -geometry +23-101 -composite
  # src: the source filename
  # scale: the scale
  # ctr_x, ctr_y: : vanishing point, coordinates relative to upper left of img
  def render_piece(src, scale, ctr_x, ctr_y)
    scale = scale.to_f
    x = ctr_x * (1 - scale)
    y = ctr_y * (1 - scale)

    "\\( \"#{src}\" -resize #{_dim(@w0, @h0, scale)} \\) -geometry #{_off(x, y)} -composite"
  end

  # render one frame of the gif
  # src_s: src for smaller image to be overlaid on main image
  # scale_b: scale for the bigger (midsize) image.
  # scale_s: scale for the smaller size image.
  # center_x, center_y: vanishing point, coordinates relative to upper left of img
  # out_path: file to write
  def render(src_s, scale_b, scale_s, center_x, center_y, out_path)
    hug = render_piece(@img_path, scale_b / scale_s, center_x, center_y)
    big = render_piece(@img_path, scale_b, center_x, center_y)
    sml = render_piece(src_s, scale_s, center_x, center_y)
    magick = "convert -size #{_dim(@w0, @h0)} xc:none #{hug} #{big} #{sml} \"#{out_path}\""
    cmd(magick)
  end

  # MAIN ENTRY POINT
  # output_file: what to write
  # dir: temp directory
  # center_x, center_y: vanishing point, coordinates relative to upper left of img
  # min_w, min_h: the bounding box for the smaller image
  # step_size: rougly in pixels, how much to zoom in per frame.
  def process(output_file, dir, center_x, center_y, min_w, min_h, step_size)
    # figure out the scale factor to use based on the bounding box
    sw = min_w.to_f / @w0
    sh = min_h.to_f / @h0
    proportion = [sw, sh].min

    # pre render some zoom levels.  this pre-inserts the small image into the big one.
    t1 = File.join(dir, "tmp.png")
    t2 = File.join(dir, "tmp2.png")
    render(@img_path, 1, proportion, center_x, center_y, t1)
    render(t1, 1, proportion, center_x, center_y, t2)

    # upper bound is the number of times that we multiply by to return to the same scale
    ubound = 1 / proportion
    puts "ubound: #{ubound}"

    # calculate the number of frames based on pixel measurement, because the math is easier
    # and the result is the same
    n_frames = (sw > sh ? @h0 - min_h : @w0 - min_w) / step_size

    # go exponential, not linear -- scale by proprtion, not pixels. so find the nth root
    # where n is n_frames
    root = ubound ** (1.0 / n_frames)
    puts "root is #{root}"
    puts "rooted ubound is #{root ** n_frames}"
    puts "frmes: #{n_frames}"

    # render all the frames individually, save their names for later
    frames = []
    (0...n_frames).each do |i|
      num = format("%04d", i)
      name = File.join(dir, "frame#{num}.png")
      hiscale = root ** i  # in other words (1 * (root ** i))
      loscale = hiscale * proportion
      #puts "#{name}, #{hiscale}, #{loscale}"
      render(t2, hiscale, loscale, center_x, center_y, name)
      frames << name
    end

    # create the one big gif
    magick = "convert -delay 10 -loop 0 \"#{frames.join('" "')}\" \"#{output_file}\""
    cmd(magick)
  end

end

# usage function to display help for the hapless user
def usage
  mycmd = File.basename($0)
  puts mycmd
  puts "usage: #{mycmd} input_file output_file center_x center_y minimum_w minimum_h stepsize"
  puts
  puts "Creates an animated gif with a zooming effect from input_file and saves it to output_file"
  puts "center_x, center_y represent the vanishing point, in pixels from the upper left of the image"
  puts "minimum_x, minimum_y represent the bounding box of the size that the image should zoom into"
  puts "stepsize is (roughly) the number of pixels to enlarge by.  or maybe I miscalculated."
end

# check arg length and warn user
if ARGV.length < 7
  usage
  exit 1
end

# extract args
input_file = ARGV[0]
output_file = ARGV[1]
ctr_x = ARGV[2].to_i
ctr_y = ARGV[3].to_i
min_w = ARGV[4].to_i
min_h = ARGV[5].to_i
step_size = ARGV[6].to_i

# put it all in a temp dir
Dir.mktmpdir do |dir|
  puts "My new temp dir: #{dir}"

  z = Zoomer.new(input_file)
  z.process(output_file, dir, ctr_x, ctr_y, min_w, min_h, step_size)

end
