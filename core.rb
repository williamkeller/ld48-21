class Core
  MAP_WIDTH = 20
  WALL_RE = /\-/
  LOOKAHEAD = 12
  
  
  def load(name)
    @rows = File.readlines(File.join "maps", name)
    reset
  end
  
  
  def reset
    @current_position = @rows.length - 1
  end
  
  
  def current_position
    @current_position
  end
  
  
  def row_count
    @rows.length
  end
  
  
  def advance
    @current_position -= 1
    index = @rows[@current_position - LOOKAHEAD].index /x/
    if index
      @spawn_callback.call index, "monster"
    end
    
    index = @rows[@current_position - LOOKAHEAD].index /&/
    if index
      row = @rows[@current_position - LOOKAHEAD]
      @msg_callback.call 0, row.slice(index + 2, row.length)
    end
    
  end
  
  
  def row(index)
    @rows[index].slice(0, MAP_WIDTH)  # sanitize
  end
  
  
  def spawn_at(&callback)
    @spawn_callback = callback
  end
  
  
  def message_at(&callback)
    @msg_callback = callback
  end
  
  
  # Returns a collection of possible collisions, based on a one
  # tile border around the provided coords
  def possible_collisions(coords)
    left_edge = (coords[0] == 0) ? 0 : coords[0] - 1
    right_edge = (coords[0] >= MAP_WIDTH) ? MAP_WIDTH : coords[0] + 1
    tiles = Array.new
    
    (-1..1).each do |row_index|
      row = @rows[coords[1] + row_index]
      (left_edge..right_edge).each do |col|
        tiles << [col, coords[1] + row_index] if [45, 60, 62, 64, 124].index row[col]
      end
    end
    tiles
  end

  def dump
    puts "*** Map file ***"
    puts "    current_position = #{@current_position}"
  end
end