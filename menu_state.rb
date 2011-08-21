class MenuState
  
  def initialize(window)
    @wnd = window
    @font = Gosu::Font.new @wnd, "Courier", 40
  end
  

  def update
    if @wnd.button_down? Gosu::KbS
      @start_handler.call
    end
  end
  

  def draw
    @font.draw "Press s to start", 200, 100, 3, 1, 1
  end
  
  
  def when_start(&handler)
    @start_handler = handler
  end
end