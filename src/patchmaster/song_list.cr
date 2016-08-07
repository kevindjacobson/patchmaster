# A SongList is a list of Songs.
class SongList

  @name : String
  @songs : Array(Song)

  property name, songs

  def initialize(@name : String)
    @songs = [] of Song
  end

  def size
    @songs.size
  end

  def <<(song)
    @songs << song
  end

  # Returns the first Song that matches +name+. +name+ may be either a
  # Regexp or a String. The match will be made case-insensitive.
  def find(name_regex)
    name_regex = Regexp.new(name_regex.to_s, true) # make case-insensitive
    @songs.find { |s| s.name =~ name_regex }
  end
end
