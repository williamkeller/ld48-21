
CLIP_TOP = 10
CLIP_BOTTOM = SCREEN_Y - 10

class Player
  attr_accessor :x, :y, :backups
  @@images = Array.new
  
  def self.images
    @@images
  end
  
  
  def initialize(window)
    @wnd = window
    @x = 0
    @y = 0
    @backups = 3
    
    @angle = 0
    @trail = Array.new(8) { [0, 0] }
    @trail_index = 0
    @trail_delay = 0
  end
  
  
  def update
    @trail_delay = (@trail_delay + 1) % 3
    if @trail_delay == 0
      @trail_index = (@trail_index + 1) % 8
      @trail[@trail_index] = [@x, @y]
      coords = @trail[(@trail_index + 7) % 8]
      @angle = Gosu::angle(coords[0], coords[1], @x, @y)
    end
    
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
    
    if @y >= CLIP_BOTTOM
      @y = CLIP_BOTTOM
    elsif @y <= CLIP_TOP
      @y = CLIP_TOP
    end
  end
  
  
  def draw
    @@images[0].draw_rot @x - 16, @y - 16, 1, @angle
  end
  
  
  def coords
    [@x, @y]
  end
  
  
  def box
    [@x - 10, @y - 10, @x + 10, @y + 10]
  end
  
end