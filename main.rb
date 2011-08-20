require "rubygems"
require "gosu"
require "daemon"
require "player"
require "core"

class GameWindow < Gosu::Window
  
  SCREEN_X = 640
  SCREEN_Y = 480
  TILES_X = 15 
  TILES_Y = 14
  BLIT_SPEED = 3
  CHASE_INTERVAL = 10
  
  
  def initialize
    super SCREEN_X, SCREEN_Y, false
    self.caption = "Escape deletion"

    @tile_images = Hash.new
    @tile_images[124] = Gosu::Image.new self, "media/images/wall-1.png", true   #   |
    @tile_images[45] = Gosu::Image.new self, "media/images/wall-2.png", true    #   -
    @tile_images[62] = Gosu::Image.new self, "media/images/wall-3.png", true    #   >
    @tile_images[60] = Gosu::Image.new self, "media/images/wall-4.png", true    #   <

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

    d = Daemon::new
    d.loc = [320, 440]
    d.target_loc @player.x, @player.y
    @daemons << d

    d = Daemon::new
    d.loc = [120, 440]
    d.target_loc @player.x, @player.y
    @daemons << d

    d = Daemon::new
    d.loc = [420, 440]
    d.target_loc @player.x, @player.y
    @daemons << d
    
    @chase_counter = 0
    
    @core = Core.new
    @core.load "core1.txt"
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
    
    @player.update
    
   @daemons.each { |d| d.update }
  end
  
  
  def draw
    (-1..TILES_Y).each do |row_index|
      row = @core.row(@core.current_position - TILES_Y + row_index)
      y = (row_index * 32) + 10 + @scroll_offset
      (0..TILES_X).each do |col_index|
        x = (col_index * 32) + 10
        img = @tile_images[row[col_index]]

        unless img.nil?
          img.draw x, y, 1
        end
      end
    end
        
    @player.draw
    
    @daemons.each { |d| d.draw }
  end
  
  
  def button_down(key_id)
    close if key_id == Gosu::KbEscape
  end
  
end


def main
  window = GameWindow.new
  window.show
end


main