require "rubygems"
require "gosu"
require "daemon"
require "player"

class GameWindow < Gosu::Window
  
  SCREEN_X = 640
  SCREEN_Y = 480
  BLIT_SPEED = 3
  
  def initialize
    super SCREEN_X, SCREEN_Y, false
    self.caption = "Escape deletion"

    @grid = Gosu::Image.new self, "media/images/grid.png", true
    @wall1 = Gosu::Image.new self, "media/images/wall-1.png", true
    @blit = Gosu::Image.new self, "media/images/blip.png", true
    @scroll_offset = 0
    
    #Player
    Player.images << Gosu::Image.new(self, "media/images/blip.png", true)
    @player = Player.new(self)
    @player.x = 400
    @player.y = 300
    
    # Daemon
    Daemon.image = Gosu::Image.new self, "media/images/daemon.png", true
    @daemon = Daemon.new
    @daemon.x = 320
    @daemon.y = 240
  end
  
  
  def update
    @scroll_offset = (@scroll_offset + 1) % 32
    
    @player.update
    @daemon.update
  end
  
  
  def draw
    (3..17).each do |x|
      (0..20).each do |y|
        @grid.draw x * 32, y * 32 + @scroll_offset, 0
      end
    end
    (1..20).each do |y|
      @wall1.draw 64, y * 32, 0
      @wall1.draw 576, y * 32, 0
    end
    
#    @blit.draw @player_x, @player_y, 1
    @player.draw
    
    #daemon test
    # @daemon.draw 320, 200, 1, 1.0, 1.0, 0xffffffff
    # @daemon.draw 320, 240, 1, 1.0, 1.0, 0x7fffffff
    @daemon.draw
  end
  
  def button_down(key_id)
    close if key_id == Gosu::KbEscape
  end
  
end


def main
  window = GameWindow.new
  window.show
end


main