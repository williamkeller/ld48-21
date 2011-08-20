SCALE_ANIM = [1.0, 0.9, 0.8, 0.7, 0.6, 0.7, 0.8, 0.9]
ROT_ANIM = [0, 11.25, 22.50, 33.75, 45.0, 56.25, 67.50, 78.75]
FADE_ANIM = [0xffffffff, 0xdfffffff, 0xbfffffff, 0x7fffffff, 0x5fffffff, 0x7fffffff, 0xbfffffff, 0xdfffffff]

SPEED = 2
TAIL_LENGTH = 8
TAIL_DELAY = 4

class Daemon
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
    @tail = nil
    @tail_step = 0
    @tail_delay = 0
  end
  
  
  def loc=(pos)
    @x = pos[0]
    @y = pos[1]
    @tail = Array.new(TAIL_LENGTH) { [@x, @y] }
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
    
    @tail_delay = (@tail_delay + 1) % TAIL_DELAY
    if @tail_delay == 0
      @tail[@tail_step] = [@x, @y]
      @tail_step = (@tail_step + 1) % TAIL_LENGTH
    end
    
    @x += @move_x
    @y += @move_y
  end
  
  
  def draw
    @@images[0].draw_rot @x, @y, 1, ROT_ANIM[@anim_step], 0.5, 0.5,
      SCALE_ANIM[@anim_step], SCALE_ANIM[@anim_step], FADE_ANIM[@anim_step]

    tail_color = 0x3fffffff
    (0..TAIL_LENGTH - 1).each do |index|
      tail = @tail[(@tail_step + index) % TAIL_LENGTH]
      @@images[1].draw tail[0], tail[1], 1, 1.0, 1.0, tail_color
      tail_color += 0x10000000
    end

  end
  
end