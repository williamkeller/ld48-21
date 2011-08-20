require "rubygems"
require "gosu"

class GameWindow < Gosu::Window
  
  SCREEN_X = 640
  SCREEN_Y = 480
  BLIT_SPEED = 3
  
  def initialize
    super SCREEN_X, SCREEN_Y, false
    self.caption = "Escape deletion"

    @grid = Gosu::Image.new self, "media/images/grid.png", true
    @wall1 = Gosu::Image.new self, "media/images/wall-1.png", true
    @blit = Gosu::Image.new self, "media/images/blit.png", true
    @scroll_offset = 0
    
    @player_x = 400
    @player_y = 300
  end
  
  
  def update
    @scroll_offset = (@scroll_offset + 1) % 32
    
    if button_down? Gosu::KbLeft
      @player_x -= BLIT_SPEED
    end
    
    if button_down? Gosu::KbRight
      @player_x += BLIT_SPEED
    end
    
    if button_down? Gosu::KbUp
      @player_y -= BLIT_SPEED
    end
    
    if button_down? Gosu::KbDown
      @player_y += BLIT_SPEED
    end

  end
  
  
  def draw
    (0..20).each do |x|
      (0..20).each do |y|
        @grid.draw x * 32, y * 32 + @scroll_offset, 0
      end
    end
    (1..20).each do |y|
      @wall1.draw 64, y * 32, 0
      @wall1.draw 576, y * 32, 0
    end
    
    @blit.draw @player_x, @player_y, 1
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