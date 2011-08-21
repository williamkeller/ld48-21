require "rubygems"
require "gosu"
require "constants"
require "game_state"

class GameWindow < Gosu::Window
  
  def initialize
    super SCREEN_X, SCREEN_Y, false
    self.caption = "Escape deletion"
    
    @states = Hash.new
    @states[:game] = GameState.new(self)
    @current_state = @states[:game]
    
    
    @paused = false
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