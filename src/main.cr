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

Params = Hash(String, String? | Bool | SortBy | RGBA).new
Params["verbose"] = false
Params["dir"] = nil
Params["outfile"] = nil
Params["sortBy"] = SortBy::Filename
Params["useMagic"] = false
Params["bg"] = RGBA::MISTYROSE

OptionParser.parse { |parser|
  parser.banner = "ALBUMGRID: make a grid of album covers\n"
  parser.on("-h", "--help", "show this help message") { puts parser; exit }
  parser.on("-d DIR", "--directory DIR", "directory to get covers from") { |d| Params["dir"] = d }
  parser.on("-o FILENAME", "JPG file to output collage to") { |o| Params["outfile"] = o }
  parser.on("-v", "--verbose", "enable verbose output") { Params["verbose"] = true }
  parser.on("-s METHOD", "--sort METHOD", "sort albums by") { |s| Params["sortBy"] = SortBy.parse(s) }
  parser.on("-m", "--magic", "use libmagic to detect images instead of filenames (real slow)") { |m| Params["useMagic"] = true }
  if ARGV.size == 0
    puts parser
    exit
  end
}

checkArgs(Params, {"outfile" => "You have to specify a JPG file to which to output the collage.",
                   "dir" => "You have to specify a directory."})

# The 🍖 & 🥔
images = getCovers
save(collage(images), Params["outfile"])
