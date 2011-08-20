class Core
  
  def load(name)
    @rows = File.readlines(File.join "maps", name)
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
    index = @rows[@current_position - 15].index /x/
    if index
      @spawn_callback.call index, "monster"
    end
  end
  
  
  def row(index)
    @rows[index].slice(0, 15)  # sanitize
  end
  
  
  def spawn_at(&callback)
    @spawn_callback = callback
  end

end