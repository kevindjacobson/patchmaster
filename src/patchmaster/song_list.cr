# A SongList is a list of Songs.
class SongList

  property name, songs

  def initialize(@name)
    @name = name
    @songs = [] of Song
  end

  def <<(song)
    @songs << song
  end

  # Returns the first Song that matches +name+. +name+ may be either a
  # Regexp or a String. The match will be made case-insensitive.
  def find(name_regex)
    name_regex = Regexp.new(name_regex.to_s, true) # make case-insensitive
    @songs.detect { |s| s.name =~ name_regex }
  end

  def first_pach
    @songs.curr.first_patch
  end

  def prev_pach
    @songs.curr.prev_patch
  end

  def curr_pach
    @songs.curr.curr_patch
  end

  def next_pach
    @songs.curr.next_patch
  end

  def last_pach
    @songs.curr.last_patch
  end
end
