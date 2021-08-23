#!/usr/bin/env ruby

require 'json'
require 'base64'
require 'uri'

# usage function to display help for the hapless user
def usage
  mycmd = File.basename($0)
  puts mycmd
  puts "usage: #{mycmd} <har file> [output dir] [[file pattern] ...]"
  puts
  puts "Extract files matching the pattern(s) from the har file, place them in the output dir"
  puts "If no file patterns (or output directory) are provided, the files are listed."
  puts
  puts "Got #{ARGV}"
end

def url_basename(uri)
  File.basename(URI.parse(uri).path)
end

# check arg length and warn user
if ARGV.length < 1
  usage
  exit 1
end

har = JSON.parse(File.read(ARGV[0]))

files = har["log"]["entries"].each_with_object({}) do |e, acc|
  name = e["request"]["url"]
  encoding = e["response"]["content"]["encoding"]
  raw_content = e["response"]["content"]["text"]
  content = case encoding
  when "base64" then Base64.decode64(raw_content)
  else raw_content
  end
  acc[name] = content
end

if ARGV.length < 3
  files.keys.select { |f| files[f].nil? }.each { |f| puts "#{f} (#{files[f]})" }
  puts "No output directory and/or file patterns provided, exiting"
  exit 0
end

out_dir = ARGV[1]
patterns = ARGV[2..-1].map { |r| Regexp.new(r) }
matches = files.keys.select { |f| patterns.any? { |p| p.match(f) } }
ordered_matches = matches.sort_by { |name| [url_basename(name)[/\d+/].to_i, name] }
ordered_matches.each do |m|
  out_path = File.join(out_dir, url_basename(m))
  puts "Extracting #{m} to #{out_path}"
  File.write(out_path, files[m])
end
