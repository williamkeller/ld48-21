require "rubygems"
require "gosu"
require "daemon"
require "player"
require "core"
require "explosion"


# Rectangle index constants
L = 0
T = 1
R = 2
B = 3


class GameWindow < Gosu::Window
  
  SCREEN_X = 640
  SCREEN_Y = 480
  TILES_X = 15 
  TILES_Y = 14
  BLIT_SPEED = 3
  CHASE_INTERVAL = 10
  X_BORDER = 10
  Y_BORDER = 10
  TILE_SIZE = 32
  
  
  def initialize
    super SCREEN_X, SCREEN_Y, false
    self.caption = "Escape deletion"
    
    @debug_font = Gosu::Font.new self, "Courier", 20

    @tile_images = Hash.new
    @tile_images[124] = Gosu::Image.new self, "media/images/wall-1.png", true   #   |
    @tile_images[45] = Gosu::Image.new self, "media/images/wall-2.png", true    #   -
    @tile_images[62] = Gosu::Image.new self, "media/images/wall-3.png", true    #   >
    @tile_images[60] = Gosu::Image.new self, "media/images/wall-4.png", true    #   <
    @tile_images[64] = Gosu::Image.new self, "media/images/bomb.png", true      #   @

    @grid = Gosu::Image.new self, "media/images/grid.png", true
    @blit = Gosu::Image.new self, "media/images/blip.png", true
    @scroll_offset = 0
    
    #Player
    Player.images << Gosu::Image.new(self, "media/images/blip.png", true)
    @player = Player.new(self)
    @player.x = 400
    @player.y = 300
    
    # Daemons
    Daemon.images << Gosu::Image.new(self, "media/images/daemon.png", true)
    Daemon.images << Gosu::Image.new(self, "media/images/daemon-tail.png", true)
    
    @daemons = Array.new

    @chase_counter = 0
    
    @core = Core.new
    @core.load "core1.txt"
    @core.spawn_at do |col, what| 

      d = Daemon::new
      d.loc = [col * 32 + 10, 5]
      d.target_loc @player.x, @player.y
      @daemons << d
    end
    
    @paused = false
    
    Explosion.images << Gosu::Image.new(self, "media/images/blast-ring.png", true)
    @explosion_manager = ExplosionManager.new
  end
  
  
  def update
    return if @paused
    
    @scroll_offset = (@scroll_offset + 1) % 32
    if @scroll_offset == 0
      @core.advance
    end
    
    @chase_counter = (@chase_counter + 1) % CHASE_INTERVAL
    if @chase_counter == 0
      @daemons.each { |d| d.target_loc(@player.x, @player.y) }
    end
    
    @player.update
    if background_collision? @player
      @explosion_manager.spawn_explosion @player.x, @player.y
    end
    
    @daemons.each do |d| 
      if background_collision? d
        @explosion_manager.spawn_explosion d.x, d.y
        @daemons.delete d
        puts "Dumping daemon, #{@daemons.length} remain"
      else
        d.update 
      end
    end
    
    @explosion_manager.update

  end
  
  
  def draw
    (-1..TILES_Y).each do |row_index|
      row = @core.row(@core.current_position - TILES_Y + row_index)
      y = (row_index * 32) + Y_BORDER + @scroll_offset
      (0..TILES_X).each do |col_index|
        x = (col_index * 32) + X_BORDER
        img = @tile_images[row[col_index]]

        unless img.nil?
          img.draw x, y, 1
        end
      end
    end
        
    @player.draw
#    draw_tile_border @player.x, @player.y
    
    @daemons.each { |d| d.draw }
    
    coords = screen_to_map @player.coords
    @debug_font.draw "[#{coords[0]},#{coords[1]}]", 500, 10, 2
    @debug_font.draw "[#{@player.x}, #{@player.y}]", 500, 30, 2
    box = bounding_box_for_tile([8, 2213])
    @debug_font.draw "[#{box[0]}, #{box[1]}", 500, 50, 2
    @debug_font.draw "#{box[2]}, #{box[3]}]", 510, 70, 2
    
    @debug_font.draw "#{@core.current_position}", 500, 90, 2
    
    @explosion_manager.draw
  end
  

  def screen_to_map(coords)
    x = ((coords[0] + X_BORDER) / TILE_SIZE).floor
    y = @core.current_position - TILES_Y + (coords[1] / TILE_SIZE).floor
    
    [x, y]
  end
  

  def bounding_box_for_tile(coords)
    x = (coords[0] * 32) + X_BORDER

    top = @core.current_position - TILES_Y
    y = (coords[1] - top) * TILE_SIZE + Y_BORDER + @scroll_offset
    
    [x, y, x + TILE_SIZE, y + TILE_SIZE]
  end
  
  
  def button_down(key_id)
    close if key_id == Gosu::KbEscape
    
    pause if key_id == Gosu::KbSpace

    dump if key_id == Gosu::KbD
    
    if key_id == Gosu::KbE
      @explosion_manager.spawn_explosion @player.x, @player.y
    end
  end
  
  
  def pause
    @paused = @paused ? false : true
  end
  
  
  def dump
    puts "*** Debug dump ***"
    @player.dump
    @daemons.each { |d| d.dump }
    
    puts "*** Helper functions *** "
    puts "    screen_to_map(player) = #{screen_to_map(@player.coords).inspect}"
    puts "    bounding_box_for_tile(player) = #{bounding_box_for_tile(screen_to_map(@player.coords)).inspect}"
    puts "*** Collisions ***"
    test_for_collision_with_background @player, true
    @core.dump
  end
  
  # Colliding with the background
  # Convert player to map coords to see what's close
  # Get a list of possible tiles
  # Convert each possible tile into a bounding box
  # Test for collision with entity's bounding box
  def background_collision?(entity, do_dump = false)
    coords = screen_to_map(entity.coords)
    tiles = @core.possible_collisions(coords)
    box = entity.box
    puts tiles.inspect if do_dump
    tiles.each do |tile|
      return true if test_boxes_for_intersect(bounding_box_for_tile(tile), box )
    end
    
    false
  end
  
  
  # debug method to visualize tile positions
  def draw_tile_border(x, y, c = 0xffffffff)
    coords = screen_to_map([x, y])
    box = bounding_box_for_tile(coords)
    draw_quad(box[0], box[1], c, box[2], box[1], c, box[2], box[3], c, box[0], box[3], c, 0)
  end
  
  
  def test_boxes_for_intersect(box1, box2)
    ((box1[L] > box2[L] and box1[L] < box2[R]) or (box2[L] > box1[L] and box2[L] < box1[R])) and
      ((box1[T] > box2[T] and box1[T] < box2[B]) or (box2[T] > box1[T] and box2[T] < box1[B]))
  end
  
end




def main
  window = GameWindow.new
  window.show
end


main