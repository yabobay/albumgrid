@[Link("magic")]
lib LibMagic
  MAGIC_NONE = 0
  MAGIC_MIME_TYPE = 0x0000010
  alias Magic = Pointer(Void) # ¯\_(ツ)_/¯
  alias CStr = Pointer(LibC::Char)
  fun open = magic_open(flags: LibC::Int): Magic
  fun close = magic_close(cookie: Magic)
  fun file = magic_file(cookie: Magic, filename: CStr): CStr
  fun list = magic_list(cookie: Magic, filename: CStr): LibC::Int
  fun error = magic_error(cookie: Magic): CStr
  fun load = magic_load(cookie: Magic, filename: CStr): LibC::Int
end
