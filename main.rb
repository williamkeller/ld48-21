require "rubygems"
require "gosu"
require "constants"
require "daemon"
require "player"
require "core"
require "explosion"
require "game_state"

# Rectangle index constants
L = 0
T = 1
R = 2
B = 3

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
    return if @paused
    
    @current_state.update
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
  
  
  def dump
    puts "*** Debug dump ***"
    @player.dump
    @daemons.each { |d| d.dump }
    
    puts "*** Helper functions *** "
    puts "    screen_to_map(player) = #{screen_to_map(@player.coords).inspect}"
    puts "    bounding_box_for_tile(player) = #{bounding_box_for_tile(screen_to_map(@player.coords)).inspect}"
    puts "*** Collisions ***"
    test_for_collision_with_background @player, true
    @core.dump
  end
  
end




def main
  window = GameWindow.new
  window.show
end


main