include Math

def collage(imgs : Array(Canvas), bg : RGBA = RGBA::MISTYROSE) : Canvas
  gridSize = sqrt(imgs.size).ceil.to_i
  gridSizePx = gridSize * COVERSIZE
  collage = Canvas.new(gridSizePx, gridSizePx, background = bg)

  x = y = 0
  imgs.each do |img|
    collage.paste(img, x, y)
    x += COVERSIZE
    if x >= gridSizePx
      x = 0
      y += COVERSIZE
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

