require "rubygems"
require "gosu"

class GameWindow < Gosu::Window
  
  SCREEN_X = 800
  SCREEN_Y = 600
  
  def initialize
    super SCREEN_X, SCREEN_Y, false
    caption = "Escape deletion"
    
    @blank = Gosu::Image.new self, "media/images/blank.png", true
    @scroll_offset = 0
  end
  
  
  def update
    @scroll_offset = (@scroll_offset + 1) % 64
  end
  
  
  def draw
    (2..10).each do |x|
      (-1..10).each do |y|
        @blank.draw x * 64, y * 64 + @scroll_offset, 0
      end
    end
  end
  
end


def main
  window = GameWindow.new
  window.show
end


main