SCALE_ANIM = [1.0, 0.9, 0.8, 0.7, 0.6, 0.7, 0.8, 0.9]
ROT_ANIM = [0, 11.25, 22.50, 33.75, 45.0, 56.25, 67.50, 78.75]
FADE_ANIM = [0xffffffff, 0xdfffffff, 0xbfffffff, 0x7fffffff, 0x5fffffff, 0x7fffffff, 0xbfffffff, 0xdfffffff]
class Daemon
  attr_accessor :x, :y
  @@image = nil
  
  def self.image=(image)
    @@image = image
  end
  
  def initialize
    @x = 0
    @y = 0
    @anim_step = 0
    @anim_delay = 0
  end
  
  
  def update
    @anim_delay = (@anim_delay + 1) % 8
    if @anim_delay == 0 
      @anim_step = (@anim_step + 1) % 8
    end
  end
  
  
  def draw
    @@image.draw_rot @x, @y, 1, ROT_ANIM[@anim_step], 0.5, 0.5,
      SCALE_ANIM[@anim_step], SCALE_ANIM[@anim_step], FADE_ANIM[@anim_step]
  end
  
end