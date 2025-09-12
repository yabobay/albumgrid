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

def checkArgs(required)
  required.each do |k, v|
    (puts "#{v}\nDo `collage -h` for more info."; exit 1) if k.empty?
  end
end

directory = ""
outfile = ""
verbose = false
sortBy = SortBy::Filename

OptionParser.parse { |parser|
  parser.banner = "ALBUMGRID: make a grid of album covers\n"
  parser.on("-h", "--help", "show this help message") { puts parser; exit }
  parser.on("-d DIR", "--directory DIR", "directory to get covers from") { |d| directory = d }
  parser.on("-o FILENAME", "JPG file to output collage to") { |o| outfile = o }
  parser.on("-v", "--verbose", "enable verbose output") { verbose = true }
  parser.on("-s METHOD", "--sort METHOD", "sort albums by") { |s| sortBy = SortBy.parse(s) }
  if ARGV.size == 0
    puts parser
    exit
  end
}

checkArgs({outfile => "You have to specify a JPG file to which to output the collage.",
           directory => "You have to specify a directory."})

params = Hash(String, String | Bool | SortBy | RGBA).new
params["verbose"] = verbose
params["dir"] = directory
params["sortby"] = sortBy

# The 🍖 & 🥔
images = getCovers(params)
save(collage(images), outfile)
