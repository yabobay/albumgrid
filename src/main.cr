require "stumpy_core"
require "stumpy_png"
require "pluto"
require "pluto/format/jpeg"
require "option_parser"

require "./getCovers.cr"
require "./collage.cr"

include StumpyCore

COVERSIZE = 128 # size of each cover in the grid

class Option end

enum SortBy
  Filename
  Random
end

def checkArgs(params, required)
  required.each do |k, v|
    (puts "#{v}\nDo `collage -h` for more info."; exit 1) if params[k].nil?
  end
end

params = Hash(String, String? | Bool | SortBy | RGBA).new
params["verbose"] = false
params["dir"] = nil
params["outfile"] = nil
params["sortBy"] = SortBy::Filename
params["useMagic"] = false

OptionParser.parse { |parser|
  parser.banner = "ALBUMGRID: make a grid of album covers\n"
  parser.on("-h", "--help", "show this help message") { puts parser; exit }
  parser.on("-d DIR", "--directory DIR", "directory to get covers from") { |d| params["dir"] = d }
  parser.on("-o FILENAME", "JPG file to output collage to") { |o| params["outfile"] = o }
  parser.on("-v", "--verbose", "enable verbose output") { params["verbose"] = true }
  parser.on("-s METHOD", "--sort METHOD", "sort albums by") { |s| params["sortBy"] = SortBy.parse(s) }
  parser.on("-m", "--magic", "use libmagic to detect images instead of filenames (real slow)") { |m| params["useMagic"] = true }
  if ARGV.size == 0
    puts parser
    exit
  end
}

checkArgs(params, {"outfile" => "You have to specify a JPG file to which to output the collage.",
                   "dir" => "You have to specify a directory."})

# The 🍖 & 🥔
images = getCovers(params)
save(collage(images), params["outfile"])
