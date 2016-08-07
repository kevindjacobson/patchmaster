require "./song_list"

class SortedSongList < SongList
  def first
    @songs.first
  end

  def <<(song)
    next_song_after = @songs.find { |s| s.name > song.name }
    if next_song_after
      i = @songs.index(next_song_after).not_nil!
      @songs.insert(i, song)
    else
      super(song)
    end
  end
end
