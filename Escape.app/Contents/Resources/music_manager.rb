class MusicManager
  
  def initialize(window)
    @wnd = window
    
    @songs = Hash.new
  end
  
  
  def songs
    @songs
  end
  
  
  def play(song_id, looping = true)
    @songs[song_id].play looping
  end
  
  
  def stop
    Gosu::Song.current_song.stop if Gosu::Song.current_song
  end
  
end