include Math

def collage(imgs : Array(Canvas)) : Canvas
  coverSize = Params["coverSize"].as Int
  gridSize = sqrt(imgs.size).ceil.to_i
  gridSizePx = gridSize * coverSize
  collage = Canvas.new(gridSizePx, gridSizePx, background = Params["bg"].as RGBA)

  x = y = 0
  imgs.each do |img|
    collage.paste(img, x, y)
    x += coverSize
    if x >= gridSizePx
      x = 0
      y += coverSize
    end
  end
  return collage
end

def save(img : Canvas, filename)
  filename = filename.as(String)
  io = IO::Memory.new
  Pluto::ImageRGBA.from_stumpy(img).to_jpeg(io)
  io.rewind
  File.write(filename, io)
end

