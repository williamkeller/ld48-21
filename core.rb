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
  end
  
  
  def row(index)
    @rows[index].slice(0, 15)  # sanitize
  end

end