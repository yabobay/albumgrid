require "./libmagic.cr"

def getCovers(params : Hash) : Array(Canvas)
  images = Array(Canvas).new
  filenames = find params["dir"].as(String) { |x| isImage(x, params["useMagic"]) }
  
  case params["sortBy"]
  when SortBy::Filename
    filenames.sort! { |a, b| a.downcase <=> b.downcase }
  when SortBy::Random
    filenames.sort! { [-1, 1].sample }
  end

  filenames.each_with_index do |filename, i|
    print "\rProcessing file #{i+1}/#{filenames.size}..." if params["verbose"]
    img = filename2imagergba(filename)
    images.push downscale(img).to_stumpy if img
  end
  puts " done" if params["verbose"]

  return images
end

def downscale(img : Pluto::ImageRGBA) : Pluto::ImageRGBA
  img.bilinear_resize(COVERSIZE, COVERSIZE)
end

def downscale(img : Canvas) : Pluto::ImageRGBA
  downscale(Pluto::ImageRGBA.from_stumpy img)
end

enum ImageKind
  Jpg
  Png
end

def imageKind(filename : String) : ImageKind?
  case fileExtension filename
  when "jpg", "jpeg"
    ImageKind::Jpg
  when "png"
    ImageKind::Png
  else
    nil
  end
end

def isImage(filename : String, magic = false) : Bool
  if magic
    cookie = LibMagic.open(LibMagic::MAGIC_MIME_TYPE)
    LibMagic.load(cookie, LibMagic::CStr.null) # load default magic database
    desc = LibMagic.file(cookie, filename)
    raise String.new(LibMagic.error(cookie)) if desc.null?
    desc = String.new(desc)
    return desc.starts_with? "image/"
  else
    ["png", "jpg", "jpeg"].includes? fileExtension(filename)
  end
end

def fileExtension(filename : String) : String
  filename[filename.rindex('.')..].lchop
end

def filename2imagergba(filename : String) : (Pluto::ImageRGBA|Canvas)?
  file = File.open(filename)
  img = case imageKind(filename)
        when ImageKind::Jpg
          Pluto::ImageRGBA.from_jpeg(file)
        when ImageKind::Png
          StumpyPNG.read(file)
        else
          nil
        end
  file.close
  return img
end

def find(directory : String) : Array(String)
  find(directory) { true }
end

def find(directory : String, &condition : String -> Bool) : Array(String)
  filenames = Array(String).new
  dir = Dir.new(directory)
  dir.children
    .select { |x| x[0] != '.' }
    .map { |x| Path.new(dir.path)./(x).to_s }
    .each do |x|
    begin
      filenames += find(x, &condition)
    rescue File::Error
      filenames << x if condition.call(x)
    end
  end
  return filenames
end
