def getCovers(params : Hash) : Array(Canvas)
  images = Array(Canvas).new
  # get filenames.
  filenames = find(params["dir"]) { |x| ["png", "jpg", "jpeg"].includes? filetype(x) }
  
  case params["sortby"]
  when "filename"
    filenames.sort! { |a, b| a.downcase <=> b.downcase }
  when "random"
    filenames.sort! { [-1, 1].sample }
  end

  verbose = !params["verbose"].empty?

  filenames.each_with_index do |filename, i|
    print "\rProcessing file #{i+1}/#{filenames.size}..." if verbose
    img = filename2imagergba(filename)
    images.push downscale(img).to_stumpy if img
  end
  puts " done" if verbose

  return images
end

def downscale(img : Pluto::ImageRGBA) : Pluto::ImageRGBA
  img.bilinear_resize(COVERSIZE, COVERSIZE)
end

def downscale(img : Canvas) : Pluto::ImageRGBA
  downscale(Pluto::ImageRGBA.from_stumpy img)
end

def filetype(filename : String) : String
  # TODO: get the file type using magic or something instead.
  filename[filename.rindex('.')..].lchop  
end

def filename2imagergba(filename : String) : (Pluto::ImageRGBA|Canvas)?
  file = File.open(filename)
  img = case filetype(filename)
        when "jpg", "jpeg"
          Pluto::ImageRGBA.from_jpeg(file)
        when "png"
          StumpyPNG.read(file)
        else
          nil # TODO: add more image formats please
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
