# A Song is a named list of Patches.
class Song

  property name, patches, notes

  def self.empty
    @@empty ||= Song.new("Unnamed")
  end

  def initialize(@name : String)
    @patches = [Patch.empty]
    @notes = ""
    PatchMaster.instance.all_songs << self
  end

  def <<(patch)
    @patches << patch
  end

end
