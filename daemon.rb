SCALE_ANIM = [1.0, 0.9, 0.8, 0.7, 0.6, 0.7, 0.8, 0.9]
ROT_ANIM = [0, 11.25, 22.50, 33.75, 45.0, 56.25, 67.50, 78.75]
FADE_ANIM = [0xffffffff, 0xdfffffff, 0xbfffffff, 0x7fffffff, 0x5fffffff, 0x7fffffff, 0xbfffffff, 0xdfffffff]

ANIM_STEPS = 8
SPEED = 2
TAIL_LENGTH = 12
TAIL_DELAY = 4
ANGLE_NOISE = 40
ANGLE_NOISE_2 = (ANGLE_NOISE / 2)


class DaemonManager
  
  def initialize
    @daemons = Array.new
  end
  
  
  def update
    
  end
  
  
  def draw
    
  end
  
  
  def spawn(x, y)
    
  end
end


class Daemon
  attr_accessor :x, :y
  
  @@images = Array.new
  
  def self.images
    @@images
  end
  
  def initialize
    @anim_step = rand(ANIM_STEPS)
    @anim_delay = 0
    @tail = nil
    @tail_step = 0
    @tail_delay = 0
  end
  
  
  def loc=(pos)
    @x = pos[0]
    @y = pos[1]
    @tail = Array.new(TAIL_LENGTH) { [@x, @y] }
  end
  
  
  def coords
    [@x, @y]
  end
  
  
  def box
    [@x - 16, @y - 16, @x + 16, @y + 16]
  end
  
  
  def target_loc(x, y)
    
    target_angle = (Gosu::angle(@x, @y, x, y) + rand(ANGLE_NOISE) - ANGLE_NOISE_2).gosu_to_radians
    
    @move_x = Math::cos(target_angle) * SPEED
    @move_y = Math::sin(target_angle) * SPEED
    
  end
  
  
  def update
    @anim_delay = (@anim_delay + 1) % 8
    if @anim_delay == 0 
      @anim_step = (@anim_step + 1) % 8
    end
    
    @tail_delay = (@tail_delay + 1) % TAIL_DELAY
    if @tail_delay == 0
      @tail[@tail_step] = [@x - 16, @y - 16]
      @tail_step = (@tail_step + 1) % TAIL_LENGTH
    end
    
    @x += @move_x
    @y += @move_y
  end
  
  
  def draw
    @@images[0].draw_rot @x, @y, 1, ROT_ANIM[@anim_step], 0.5, 0.5,
      SCALE_ANIM[@anim_step], SCALE_ANIM[@anim_step], FADE_ANIM[@anim_step]

    tail_color = 0xffffffff
    (0..TAIL_LENGTH).each do |index|
      index = TAIL_LENGTH - index - 1
      tail = @tail[(@tail_step + index) % TAIL_LENGTH]
      @@images[1].draw tail[0], tail[1], 1, 1.0, 1.0, tail_color
      tail_color -= 0x10000000
    end

  end
  
  def dump
    puts "== Daemon =="
    puts "   x = #{@x}"
    puts "   y = #{@y}"
    puts "   move_x = #{@move_x}"
    puts "   move_y = #{@move_y}"
    puts "   anim_step = #{@anim_step}"
  end
  
end