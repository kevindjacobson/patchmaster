# A CodeChunk holds a block of code (lambda, block, proc) and the text that
# created it as read in from a PatchMaster file.
class CodeChunk

  property block, text

  def initialize(@block, @text=nil)
  end

  def run(*args)
    block.call(*args)
  end

  def to_s
    "#<CodeChunk block=#{block.inspect}, text=#{text.inspect}>"
  end
end
