

SCALE_STEPS = [0.1, 0.2, 0.3, 0.45, 0.6, 0.8, 1.0, 1.2]
FADE_STEPS = [0xffffffff, 0xefffffff, 0xdfffffff, 0xbfffffff, 0x9fffffff, 0x7fffffff, 0x5fffffff, 0x3fffffff]
ANIM_DELAY = 4


class ExplosionManager
  
  def initialize
    @explosions = Array.new
  end
  
  
  def update
    @explosions.each do |ex|
      if ex.finished?
        @explosions.delete ex
        puts "dumping explosion"
      else
        ex.update
      end
    end
  end
  
  
  def draw
    @explosions.each do |ex|
      ex.draw
    end
  end
  
  
  def spawn_explosion(x, y)
    ex = Explosion.new
    ex.loc = [x, y]
    @explosions << ex
  end
end

$explosions = ExplosionManager.new

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