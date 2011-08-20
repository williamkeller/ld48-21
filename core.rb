class Core
  
  def load(name)
    @rows = File.readlines(File.join "maps", name)
  end
  
  
  def row_count
    @rows.length
  end
  
  
  def row(index)
    @rows[index]
  end

end