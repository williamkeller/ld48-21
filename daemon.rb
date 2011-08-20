SCALE_ANIM = [1.0, 0.9, 0.8, 0.7, 0.6, 0.7, 0.8, 0.9]
ROT_ANIM = [0, 11.25, 22.50, 33.75, 45.0, 56.25, 67.50, 78.75]
FADE_ANIM = [0xffffffff, 0xdfffffff, 0xbfffffff, 0x7fffffff, 0x5fffffff, 0x7fffffff, 0xbfffffff, 0xdfffffff]

SPEED = 2

class Daemon
  attr_accessor :x, :y
  @@images = Array.new
  
  def self.images
    @@images
  end
  
  def initialize
    @x = 0
    @y = 0
    @anim_step = 0
    @anim_delay = 0

    @move_x = 0
    @move_y = 0
  end
  
  
  def target_loc(x, y)
    
    target_angle = (Gosu::angle(@x, @y, x, y) + rand(30) - 15).gosu_to_radians
    
    @move_x = Math::cos(target_angle) * SPEED
    @move_y = Math::sin(target_angle) * SPEED
    
  end
  
  
  def update
    @anim_delay = (@anim_delay + 1) % 8
    if @anim_delay == 0 
      @anim_step = (@anim_step + 1) % 8
    end
    
    @x += @move_x
    @y += @move_y
  end
  
  
  def draw
    @@images[0].draw_rot @x, @y, 1, ROT_ANIM[@anim_step], 0.5, 0.5,
      SCALE_ANIM[@anim_step], SCALE_ANIM[@anim_step], FADE_ANIM[@anim_step]
  end
  
end