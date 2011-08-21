$LOAD_PATH << "."

require "rubygems"
require "gosu"
require "constants"
require "menu_state"
require "game_state"
require "music_manager"
require "sound_manager"

class GameWindow < Gosu::Window
  
  def initialize
    super SCREEN_X, SCREEN_Y, false
    self.caption = "Escape deletion"

    $music = MusicManager.new(self)
    $music.songs[:menu] = Gosu::Song.new(self, "media/music/menu.ogg")
    $sounds = SoundManager.new(self)
    
    
    @states = Hash.new
    
    state = MenuState.new(self)
    state.when_start do
      @current_state = @states[:game]
    end
    @states[:menu] = state 
    
    state = GameState.new(self)
    state.when_game_over do
      puts "Game over detected"
      close
    end
    @states[:game] = state

    @current_state = @states[:menu]
    
    @paused = false
    @current_state.start
  end
  
  
  def update
    @current_state.update unless @paused
  end
  
  
  def draw
    @current_state.draw
  end
  

  def button_down(key_id)
    close if key_id == Gosu::KbEscape
    
    pause if key_id == Gosu::KbSpace

    dump if key_id == Gosu::KbD
    
    if key_id == Gosu::KbE
      @explosion_manager.spawn_explosion @player.x, @player.y
    end
  end
  
  
  def pause
    @paused = @paused ? false : true
  end
end



def main
  window = GameWindow.new
  window.show
end


main