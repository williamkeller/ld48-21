
class Bullet
  LIFESPAN = 400
  
  @@images = Array.new
  
  
  def initialize(x, y, move_x, move_y)
    @x = x
    @y = y
    @move_x = move_x
    @move_y = move_y
    @life = 0
  end
  
  
  def self.images
    @@images
  end

  
  def update
    return if @life == -1
    
    @life += 1
    @life = -1 if @life == LIFESPAN
    
    @x += @move_x
    @y += @move_y
  end
  
  
  def draw
    @@images[0].draw_rot @x, @y, 1, rand(360)
  end
  
  def finished?
    @life == -1
  end
  
  def box
    [@x - 4, @y - 4, @x + 4, @y + 4]
  end
  
end


class Turret
  FIRE_DELAY = 10
  BULLET_SPEED = 3.0
  
  @@images = Array.new
  
  attr_accessor :x, :y
  
  def self.images
    @@images
  end
  
  
  def initialize(x, y)
    @x = x
    @y = y
    @fire_delay = rand(FIRE_DELAY)
    @angle = 0
  end
  
  
  def update
    @y += 1
  end
  
  
  def draw
#    @@images[0].draw @x, @y, 1
    @@images[0].draw_rot @x, @y, 1, @angle
  end
  
  
  def target_loc(x, y)
    @angle = Gosu::angle @x, @y, x, y
    
    @fire_delay = (@fire_delay + 1) % FIRE_DELAY
    if @fire_delay == 0
      angle = @angle.gosu_to_radians
      move_x = Math::cos(angle) * BULLET_SPEED
      move_y = Math::sin(angle) * BULLET_SPEED

      $sounds.queue_sound :bullet

      Bullet.new @x + 16, @y + 16, move_x, move_y
    end
  end
end