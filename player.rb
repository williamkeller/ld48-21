BLIT_SPEED = 3

class Player
  attr_accessor :x, :y
  @@images = Array.new
  
  def self.images
    @@images
  end
  
  
  def initialize(window)
    @wnd = window
    @x = 0
    @y = 0
  end
  
  def update
    if @wnd.button_down? Gosu::KbLeft
      @x -= BLIT_SPEED
    end
    
    if @wnd.button_down? Gosu::KbRight
      @x += BLIT_SPEED
    end
    
    if @wnd.button_down? Gosu::KbUp
      @y -= BLIT_SPEED
    end
    
    if @wnd.button_down? Gosu::KbDown
      @y += BLIT_SPEED
    end

  end
  
  
  def draw
    @@images[0].draw @x, @y, 1    
  end
  
end