class SoundManager
  
  def initialize(window)
    @wnd = window
    
    @sounds = Hash.new
    
    @sounds[:explosion] = Gosu::Sample.new @wnd, "media/sounds/explosion.wav"
    @sounds[:player] = Gosu::Sample.new @wnd, "media/sounds/explosion2.wav"
    @sounds[:bullet] = Gosu::Sample.new @wnd, "media/sounds/bullet-fire.wav"
    @sounds[:loading] = Gosu::Sample.new @wnd, "media/sounds/loading.wav"
    @sounds[:impact] = Gosu::Sample.new @wnd, "media/sounds/bullet-impact.wav"
  end
  
  def queue_sound(sound_id)
    @sounds[sound_id].play
  end
end