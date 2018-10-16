#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'


# usage function to display help for the hapless user
def usage
  mycmd = File.basename($0)
  puts mycmd
  puts "usage: #{mycmd} <in dir 1> [[in dir 2] ...] -- <out dir 1> [[out dir 2] ...]"
  puts
  puts "Copy files from 'in' dirs to matching 'out' dirs by checking dates."
  puts "All supplied directories MUST exist."
  puts
  puts "Got #{ARGV}"
end

# tuple operations relating to date
# specifically where we can refer to "specific month" or "specific day" in the same structure
class D8
  include Comparable
  attr_accessor :y
  attr_accessor :m
  attr_accessor :d
  def initialize(y, m, d); @y, @m, @d = [y, m, d]; end
  def self.of_a(arr); D8.new(*(arr.fill(nil, arr.size..2))); end # b/c splat's a token, not an operator
  def to_a; [y, m, d]; end
  def self.of_s(s); D8.of_a(s.split("_").map(&:to_i)); end
  def to_s; to_a.join("_"); end
  def ==(o); to_a.zip(o.to_a).all? { |a, b| a == b }; end
  def <=>(o); to_a.zip(o.to_a).map { |a, b| a <=> b }.find(proc { 0 }, &:nonzero?); end
  def month; D8.new(@y, @m, nil); end

  def self.of_dir(path)
    D8.of_a(path.basename.to_s.split(" ")[0].split("-").map(&:to_i))
  end
end

# we need to turn files into D8s.  That's all we know.
class Abstract
    # Provide guidelines to the implementer of this class
    def self.abstract(method, *args)
      self.class_eval("def #{method}(#{args.join('')}); raise NotImplementedError, self.class.name + ' failed to implement #{self.class.name}.#{method}'; end")
    end  
end

# we need to turn files into D8s.  That's all we know.
class Strategy < Abstract
  abstract :image_of_interest?, :path
  abstract :date_from_image, :path

  # take directory and date, return boolean
  def _dir_matches_day(some_dir, d8)
    d8 == D8.of_dir(some_dir)
  end

  # take directory and date, return boolean
  def _dir_matches_month(some_dir, d8)
    d8.month == D8.of_dir(some_dir)
  end

  # take 2 pathnames and return boolean
  def image_matches_directory_day(image_path, some_dir)
    _dir_matches_day(some_dir, date_from_image(image_path))
  end

  # take 2 pathnames and return boolean
  def image_matches_directory_month(image_path, some_dir)
    _dir_matches_month(some_dir, date_from_image(image_path))
  end
end

# return array of arrays [[src dirs], [dest dirs]]
def source_data
  separator_pos = ARGV.index("--")
  [ARGV[0..(separator_pos - 1)], ARGV[(separator_pos + 1)..-1]]
end

@cache_input = nil
# all input files as pathnames
# todo: uniq of realpath
def input_files
  if @cache_input.nil?
    @cache_input = source_data[0].map { |d| Pathname.new(d).find.select(&:file?) }.flatten.uniq 
  end
  @cache_input
end

@cache_output = nil
# all output dirs as pathnames
# todo: uniq of realpath
def output_dirs
  if @cache_output.nil?
    @cache_output = source_data[1].map { |d| Pathname.new(d).children.select(&:directory?) }.flatten.uniq
  end
  @cache_output
end

def approval(question)
  print "#{question} (y/n)?"
  begin
    system("stty raw -echo")
    chr = STDIN.getc
  ensure
    system("stty -raw echo")
  end
  ret = chr.downcase == 'y'
  puts ret
  ret
end

# print a file listing
def describe_paths(description, list)
  return if list.empty?

  puts "#{description}"
  list.each { |f| puts "  #{f}" }
end

def interactively_archive(files, matched_by, destination)
  existing_files, new_files = files.partition { |f| (destination + f.basename).exist? }

  describe_paths("The following files already exist at #{destination}", existing_files)
  
  unless new_files.empty?
    describe_paths("The following files should be copied to #{destination}", new_files)

    if approval("Copy these files matched by #{matched_by}")
      #puts "FileUtils.cp(#{new_files}, #{destination})"
      FileUtils.cp(new_files, destination, verbose: false)
    end
  end
end

def exists_in_any_destination(file_path)
  output_dirs.any? { |d| d.children.map(&:basename).include?(file_path) }
end

# collate an array of files into a hash of dest_dir => file
def collate(strategy, dated_files)
  dated_files.each_with_object({}) do |f, acc|
    key = yield(strategy.date_from_image(f))
    acc[key] = [] unless acc[key]
    acc[key] << f
  end
end


###########  Logic starts here
# step 1: read source and destination dirs from command line
# step 2: move 1:1 date matches first
#         move 1:many date matches by asking
#         move month matches
#         brute force search for already-moved files
#         report 1:0 month matches, suggest new dirs
def organize(strategy)

  # check arg length and warn user
  if ARGV.length < 3
    usage
    exit 1
  end

  separator_pos = ARGV.index("--")
  if separator_pos.nil? || separator_pos == 0 || separator_pos == ARGV.length - 1
    usage
    exit 1
  end

  # filter into images and the rest
  all_images, unrecognized = input_files.partition { |f| strategy.image_of_interest?(f) }
  describe_paths("These filenames didn't parse as timestamped images", unrecognized)

  # # print 
  # all_images.each do |f|
  #   puts "#{f.basename} #{D8.of_phone(f.basename).to_a}"
  # end

  # remove already-copied stuff, wherever it exists
  uncopied_images = all_images.reject { |f| exists_in_any_destination(f) }

  # pull out files that match destination(s) by day
  day_match_files, no_day_matches = uncopied_images.partition do |img| 
    output_dirs.count { |d| strategy.image_matches_directory_day(img, d) } > 0
  end

  # split sole-directory day matches from ambiguous
  single_day_match_files, multi_day_match_files = day_match_files.partition do |img| 
    output_dirs.count { |d| strategy.image_matches_directory_day(img, d) } == 1
  end

  # pull out matches one destination directory by month
  month_match_files, no_calendar_matches = no_day_matches.partition do |img|
    output_dirs.count { |d| strategy.image_matches_directory_month(img, d) } > 0
  end

  # split sole-directory month matches from ambiguous 
  single_month_match_files, multi_month_matches = month_match_files.partition do |img|
    output_dirs.count { |d| strategy.image_matches_directory_month(img, d) } == 1
  end


  # describe_paths("matches one day", single_day_match_files)
  # describe_paths("matches one month", single_month_match_files)

  collate_day = collate(strategy, single_day_match_files, &:to_s)

  collate_day.each do |date_key, files|
    d8 = D8.of_s(date_key)
    out_dir = output_dirs.find { |d| D8.of_dir(d) == d8 }
    interactively_archive(files, "exact unique day: #{d8}", out_dir)
  end

  collate_month = collate(strategy, single_month_match_files) { |d8| d8.month.to_s }
  collate_month.each do |date_key, files|
    d8 = D8.of_s(date_key)
    out_dir = output_dirs.find { |d| D8.of_dir(d) == d8 }
    interactively_archive(files, "exact unique month: #{d8}", out_dir)
  end

  describe_paths("matches several days", multi_day_match_files)
  describe_paths("matches several months (setup error!)", multi_month_matches)
  describe_paths("no_calendar_matches", no_calendar_matches)
end
