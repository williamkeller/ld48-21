

SCALE_STEPS = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
FADE_STEPS = [0xffffffff, 0xefffffff, 0xdfffffff, 0xcfffffff, 0xbfffffff, 0xafffffff, 0x9fffffff, 0x8fffffff]
ANIM_DELAY = 8


class Explosion

  @@images = Array.new
  
  def self.images
    @@images
  end

  
  def initialize
    @x = 320
    @y = 240
    @anim_step = 0
    @anim_delay = 0
  end


  def loc=(pos)
    @x = pos[0]
    @y = pos[1]
    @tail = Array.new(TAIL_LENGTH) { [@x, @y] }
  end

  
  def update
    return if @anim_step == -1
    
    @y += 1
    @anim_delay = (@anim_delay + 1) % ANIM_DELAY
    if @anim_delay == 0 
      @anim_step += 1
      if @anim_step > 7
        @anim_step = -1
      end
    end
  end


  def draw
    @@images[0].draw_rot @x, @y, 3, 0, 0.5, 0.5, SCALE_STEPS[@anim_step], SCALE_STEPS[@anim_step], FADE_STEPS[@anim_step]
  end
  
  def finished?
    @anim_step == -1
  end
  
  
  def reset
    @anim_step = 0
    @anim_delay = 0
    @x = 320
    @y = 240
  end
  
end