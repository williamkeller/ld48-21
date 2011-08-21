require "daemon"
require "player"
require "core"
require "explosion"

class GameState

  # player states
  ALIVE = 1
  DYING = 2
  DEAD =  3
  
  
  def initialize(window)
    @wnd = window
    
    @debug_font = Gosu::Font.new @wnd, "Courier", 20

    @tile_images = Hash.new
    @tile_images[124] = Gosu::Image.new @wnd, "media/images/wall.png", true   #   |
    @tile_images[45] = Gosu::Image.new @wnd, "media/images/wall.png", true    #   -
    @tile_images[62] = Gosu::Image.new @wnd, "media/images/wall.png", true    #   >
    @tile_images[60] = Gosu::Image.new @wnd, "media/images/wall.png", true    #   <
    @tile_images[64] = Gosu::Image.new @wnd, "media/images/bomb.png", true      #   @

    @grid = Gosu::Image.new @wnd, "media/images/grid.png", true
    @blit = Gosu::Image.new @wnd, "media/images/blip.png", true
    @scroll_offset = 0
    
    
    #Player
    Player.images << Gosu::Image.new(@wnd, "media/images/blip.png", true)
    @player = Player.new(@wnd)
    @player.x = 400
    @player.y = 300
    
    @player_state = ALIVE
    
    # How long to keep running the animation after player death
    @death_timer = 0
    
    
    # Daemons
    Daemon.images << Gosu::Image.new(@wnd, "media/images/daemon.png", true)
    Daemon.images << Gosu::Image.new(@wnd, "media/images/daemon-tail.png", true)
    
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
    
    @core.message_at do |col, msg|
      puts "Message received - #{msg}"
    end
    
    Explosion.images << Gosu::Image.new(@wnd, "media/images/blast-ring.png", true)
    @explosion_manager = ExplosionManager.new
    
  end
  
  
  def update
    @scroll_offset = (@scroll_offset + 1) % 32
    if @scroll_offset == 0
      @core.advance
    end
    
    @chase_counter = (@chase_counter + 1) % CHASE_INTERVAL
    if @chase_counter == 0
      @daemons.each { |d| d.target_loc(@player.x, @player.y) }
    end
    
    if @player_state == ALIVE
      @player.update
      if background_collision? @player
        kill_player @player.x, @player.y
      end
    elsif @player_state == DYING
      @player_timer += 1
      if @player_timer == 100
        @player_state = DEAD
        @wnd.pause
      end
    end
    
    
    @daemons.each do |d| 
      d.update
      if background_collision? d
        $explosions.spawn_explosion d.x, d.y
        
        @daemons.delete d
      elsif test_boxes_for_intersect d.box, @player.box
        kill_player d.x, d.y
        @daemons.delete d
      end
    end
    
    $explosions.update
    
  end
  
  
  def draw
    $explosions.draw
    
    (-2..TILES_Y).each do |row_index|
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
        
    @player.draw if @player_state == ALIVE
    
    @daemons.each { |d| d.draw }
    
    @debug_font.draw "[#{@core.current_position}]", 500, 20, 2
    
  end
  
  
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
  

  def test_boxes_for_intersect(box1, box2)
    ((box1[L] > box2[L] and box1[L] < box2[R]) or (box2[L] > box1[L] and box2[L] < box1[R])) and
      ((box1[T] > box2[T] and box1[T] < box2[B]) or (box2[T] > box1[T] and box2[T] < box1[B]))
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
  
  
  def kill_player(x, y)
    @player_state = DYING
    @player_timer = 0
    $explosions.spawn_explosion(x, y)
  end
  
end