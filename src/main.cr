require "stumpy_core"
require "stumpy_png"
require "pluto"
require "pluto/format/jpeg"
require "option_parser"

require "./getCovers.cr"
require "./collage.cr"

include StumpyCore

COVERSIZE = 128 # size of each cover in the grid

def checkArgs(required)
  required.each do |k, v|
    (puts "#{v}\nDo `collage -h` for more info."; exit 1) if k.empty?
  end
end

directory = ""
outfile = ""
verbose = ""

OptionParser.parse { |parser|
  parser.banner = "COLLAGE: make a grid of album covers\n"
  parser.on("-h", "--help", "show this help message") { puts parser; exit }
  parser.on("-d DIR", "--directory DIR", "directory to get covers from") { |d| directory = d }
  parser.on("-o FILENAME", "JPG file to output collage to") { |o| outfile = o }
  parser.on("-v", "--verbose", "enable verbose output") { verbose = "true" }
  if ARGV.size == 0
    puts parser
    exit
  end
}

checkArgs({outfile => "You have to specify a JPG file to which to output the collage.",
           directory => "You have to specify a directory."})

params = Hash(String, String).new
params["verbose"] = verbose
params["dir"] = directory
params["sortby"] = "filename" # TODO: add option

# The 🍖 & 🥔
images = getCovers(params)
save(collage(images), outfile)
