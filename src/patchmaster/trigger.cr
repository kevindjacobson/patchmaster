# A Trigger executes code when it sees a particular array of bytes.
# Instruments have zero or more triggers.
#
# Since we want to save them to files, we store the text representation as
# well.
class Trigger

  property bytes, code_chunk

  def initialize(@bytes, @code_chunk)
  end

  def method_missing(sym, *args)
    PatchMaster.instance.send(sym, *args)
  end

  # If +bytes+ matches our +@bytes+ array then run +@code_chunk+.
  def signal(bytes)
    if bytes == @bytes
      pm = PatchMaster.instance
      @code_chunk.run(pm)
      pm.gui.refresh if pm.gui
    end
  end

  def to_s
    "#{@bytes.inspect} => #{(@code_chunk.text || "# no block text found").gsub(/\n\s*/, "; ")}"
  end
end

