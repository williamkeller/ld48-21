
class ConsoleState
  
  LINE_SIZE = 12
  
  def initialize(window, file)
    @wnd = window
    @lines = File.readlines File.join("consoles", file)
    @font = Gosu::Font.new(@wnd, "Courier New", 12)
    @line_count = @lines.length
  end
  
  
  def start
    @current_line = 0
    @current_wait = 0
  end
  
  
  def update
    
  end
  
  
  def draw
    
    (0..@line_count).each do |line|
      @font.draw @lines[line], 20, line * LINE_SIZE, 1
    end
  end
  
  
  def when_start(&callback)
    @start_callback = callback
  end
  
end