
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
    @@images[0].draw @x - 16, @y - 16, 1    
  end
  
  
  def coords
    [@x, @y]
  end
  
  
  def box
    [@x - 16, @y - 16, @x + 16, @y + 16]
  end
  
  
  def dump
    puts "== Player =="
    puts "   coords #{@x}, #{@y}"
    puts "   box #{@x - 16}, #{@y - 16}, #{@x + 16}, #{@y + 16}"
  end
  
end