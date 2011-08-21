require "daemon"
require "turret"
require "player"
require "core"
require "explosion"

class GameState

  # player states
  LOADING = 0
  ALIVE = 1
  DYING = 2
  DEAD =  3
  
  
  def initialize(window)
    @wnd = window
    @fonts = Hash.new
    
    @debug_font = Gosu::Font.new @wnd, "Courier", 20
    @fonts[:title] = Gosu::Font.new @wnd, "Courier", 40
    @fonts[:normal] = Gosu::Font.new @wnd, "Courier", 20
    
    @tile_images = Hash.new
    @tile_images["|"] = Gosu::Image.new @wnd, "media/images/wall.png", true   #   |
    @tile_images["-"] = Gosu::Image.new @wnd, "media/images/wall.png", true    #   -
    @tile_images[">"] = Gosu::Image.new @wnd, "media/images/wall.png", true    #   >
    @tile_images["<"] = Gosu::Image.new @wnd, "media/images/wall.png", true    #   <
    @tile_images["="] = Gosu::Image.new @wnd, "media/images/eol.png", true     #   =
#    @tile_images["@"] = Gosu::Image.new @wnd, "media/images/bomb.png", true    #   @

    @grid = Gosu::Image.new @wnd, "media/images/grid.png", true
    @blit = Gosu::Image.new @wnd, "media/images/blip.png", true
    @scroll_offset = 0
    
    @p1_offset = 0
    @p1_delay = 0
    @p2_offset = 0
    @p2_delay = 0
    @load_screen_delay = 0
    
    
    #Player
    Player.images << Gosu::Image.new(@wnd, "media/images/blip.png", true)
    @player = Player.new(@wnd)
    
    
    # How long to keep running the animation after player death
    @death_timer = 0

    
    Explosion.images << Gosu::Image.new(@wnd, "media/images/blast-ring.png", true)
    
    # Daemons
    Daemon.images << Gosu::Image.new(@wnd, "media/images/daemon.png", true)
    Daemon.images << Gosu::Image.new(@wnd, "media/images/daemon-tail.png", true)
    
    @daemons = Array.new

    Turret.images << Gosu::Image.new(@wnd, "media/images/turret.png", true)
    Bullet.images << Gosu::Image.new(@wnd, "media/images/bullet.png", true)
    
    @turrets = Array.new
    @bullets = Array.new
    
    @chase_counter = 0
    
    @maps = ["core1.txt", "core2.txt"]
    load_core @maps[0]
    @current_map = 0
  end
  
  
  def update
    if @player_state == LOADING
      @load_screen_delay += 1
      if @load_screen_delay == 200
        @player_state = ALIVE
      end
      return
    end
    
    if @player_state == DEAD
      if @wnd.button_down? Gosu::KbR
        if @player.backups == 0
          @game_over_handler.call
          return
        end
        @player.x = 400
        @player.y = 300
        @daemons.clear
        @core.reset
        @player_state = ALIVE
        @player.backups -= 1
      end
      return
    end
    @scroll_offset = (@scroll_offset + 1) % 32
    if @scroll_offset == 0
      @core.advance
    end
    
    @p1_delay = (@p1_delay + 1) % 2
    if @p1_delay == 0
      @p1_offset = (@p1_offset + 1) % 64
    end

    @p2_delay = (@p2_delay + 1) % 3
    if @p2_delay == 0
      @p2_offset = (@p2_offset + 1) % 32
    end

    
    @chase_counter = (@chase_counter + 1) % CHASE_INTERVAL
    if @chase_counter == 0
      @daemons.each { |d| d.target_loc(@player.x, @player.y) }
      @turrets.each do |t| 
        b = t.target_loc(@player.x, @player.y) 
        @bullets << b unless b.nil?
      end
    end
    
    if @player_state == ALIVE
      @player.update
      if background_collision? @player
        kill_player @player.x, @player.y
        $sounds.queue_sound :player
      end
    elsif @player_state == DYING
      @player_timer += 1
      if @player_timer == 100
        @player_state = DEAD
      end
    end
    
    
    @daemons.each do |d| 
      d.update
      if background_collision? d
        $explosions.spawn_explosion d.x, d.y
        $sounds.queue_sound :explosion
        
        @daemons.delete d
      elsif test_boxes_for_intersect d.box, @player.box
        kill_player d.x, d.y
        @daemons.delete d
      end
    end
    
    @turrets.each do |t|
      t.update
      if t.y > SCREEN_Y
        @turrets.delete t
        puts "Dumping turret"
      end
    end
    
    @bullets.each do |b|
      b.update
      if b.finished?
        @bullets.delete b
        puts "dumping bullet"
      end
    end
    
    $explosions.update
    
  end
  
  
  def draw
    
    if @player_state == LOADING
      @fonts[:title].draw "Loading core 01", 200, 200, 1
      @fonts[:normal].draw "communication established", 200, 240, 1
      return
    end


    
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
    
    case @player_state
    when ALIVE
      @player.draw
    when DEAD
      @debug_font.draw "Data corruption detected", 100, 300, 1
      if @player.backups == 0
        @debug_font.draw "Restore not possible", 100, 320, 1
        @debug_font.draw "Press any key to restart system", 100, 340, 1
      end
    end    
    
    @daemons.each { |d| d.draw }
    @turrets.each { |t| t.draw }
    @bullets.each { |b| b.draw }
    
    @debug_font.draw "Backups: #{@player.backups}", 500, 460, 2
    @debug_font.draw "[#{@core.current_position}]", 500, 20, 2
    
    
    # Parallax level 1
    (0..8).each do |x|
      (-1..8).each do |y|
        @grid.draw x * 64 + X_BORDER, y * 64 + @p1_offset, 0, 2.0, 2.0, 0x5fffffff
      end
    end
    
    # Parallax level 2
    (0..18).each do |x|
      (-1..20).each do |y|
        @grid.draw x * 32 + X_BORDER, y * 32 + @p2_offset, 0, 1.0, 1.0, 0x3fffffff
      end
    end
    
  end
  
  
  def when_game_over(&handler)
    @game_over_handler = handler
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
  
  
  def load_core(name)
    @core = Core.new
    @core.load name
    
    @daemons.clear
    @turrets.clear
    @bullets.clear

    @core.spawn_at do |col, what| 
      case what
      when :daemon
        d = Daemon::new
        d.loc = [col * 32 + 10, 5]
        d.target_loc @player.x, @player.y
        @daemons << d
      
      when :turret
        t = Turret::new(col * 32 + 10, 5)
        @turrets << t
      end
      
    end
    
    @core.when_end_of_level do
      @current_map += 1
      if @current_map == @maps.length
        puts "You win!"
      else
        load_core @maps[@current_map]
      end
    end
    
    @core.message_at do |col, msg|
      puts "Message received - #{msg}"
    end
    
    @player.x = 320 + X_BORDER
    @player.y = 400
    
    @player_state = LOADING
    @load_screen_delay = 0
  end
  
end