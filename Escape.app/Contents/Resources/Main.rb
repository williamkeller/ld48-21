$LOAD_PATH.unshift File.dirname(__FILE__)

require "rubygems"
require "gosu"
require "constants"
require "daemon"
require "turret"
require "player"
require "core"
require "explosion"
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
      @current_state.start
    end
    @states[:menu] = state 
    
    state = GameState.new(self)
    state.when_game_over do
      close
    end
    @states[:game] = state

    @current_state = @states[:game]
    
    @paused = false
    @current_state.start
    $music.play :menu
  end
  
  
  def update
    @current_state.update unless @paused
  end
  
  
  def draw
    @current_state.draw
  end
  

  def button_down(key_id)
    close if key_id == Gosu::KbEscape
    
    pause if key_id == Gosu::KbP
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