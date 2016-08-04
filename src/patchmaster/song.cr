# A Song is a named list of Patches.
class Song

  property name, patches, notes

  def initialize(@name)
    @patches = [] of Patch
    PatchMaster.instance.all_songs << self
  end

  def <<(patch)
    @patches << patch
  end

end
