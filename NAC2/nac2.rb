
require 'gosu'

#used by many classes
$board_width = 602
$board_height = 602

$wndw_width = (1.2 * $board_width).round
$wndw_height = (1.2 * $board_height).round
$wndw_caption = "Naughts And Crosses"

$board_x = ($wndw_width - $board_width).round / 2 #centralises board
$board_y = ($wndw_height - $board_height).round / 2

$botright_x = $board_x + $board_width
$botright_y = $board_y + $board_height

#scene variables
$new_board = false
$gameplay_started = false
$gameplay_loaded = false
$gameplay_finished = false
$cross_win = false
$naught_win = false
$ai_moving_to_target = false

#===================================================

module DrawingTools
  def draw_and_centre(image, x, y, z, fx = 1, fy = 1)
    @x_adj = x - (fx * image.width / 2)
    @y_adj = y - (fy * image.height / 2)
    image.draw(@x_adj, @y_adj, z, fx, fy)
  end
end

#---------------------------------------------------

class Timer
  def initialize(duration_in_secs)
    @duration = duration_in_secs * 1000 #duration in ms
    @t0 = Gosu.milliseconds
    @over = false
  end

  def count
    @t = Gosu.milliseconds - @t0
    if @t >= @duration
      @over = true
    end
  end

  def elapsed
    return @t
  end

  def over?
    return @over
  end
 #Thought it might come in handy but ended up never using it
end

#---------------------------------------------------

class AI

  def initialize
  end

  def random_ai
    return [rand(1..3), rand(1..3)]
  end

  def minimax_ai
  end
 #For future AI improvements, currently AI is purely random
end

#---------------------------------------------------

class MainMenuScene < Gosu::TextInput

  FONT = Gosu::Font.new(20)
  WIDTH = 300
  LENGTH_LIMIT = 20
  PADDING = 5

  INACTIVE_COLOR  = 0xcc_666666
  ACTIVE_COLOR    = 0xcc_ff6666
  SELECTION_COLOR = 0xcc_0000ff
  CARET_COLOR     = 0xff_ffffff

  attr_reader :x, :y

  def initialize
    # It's important to call the inherited constructor.
    super()

    @cursor = Gosu::Image.new("media/cursor.png", tileable: true) #Custom Cursor
    @background_img = Gosu::Image.new("media/dark_wood_bg.jpg", tileable: true)
    @background_fx = $wndw_width / @background_img.width
    @background_fy = $wndw_height / @background_img.height

    #for text boxes
    @x1, @y1 = ($wndw_width - WIDTH)/2, 200
    @x2, @y2 = ($wndw_width - WIDTH)/2, 400
    @tb_1 = [@x1, @y1]
    @tb_2 = [@x2, @y2]
    @tb_coords = [@tb_1, @tb_2]
    @tb1_color = INACTIVE_COLOR
    @tb2_color = INACTIVE_COLOR
    @tb1_selected = false
    @tb2_selected = false
    @tb1_text = []
    @tb2_text = []
    @txt_length_max = 20

    #for buttons
    @b1_width, @b1_height = 130, 31
    @b2_width, @b2_height = 130, 31
    @b3_width, @b3_height = 130, 31
    @x_1, @y_1 = 580, 195 #coordinates for respective quads
    @x_2, @y_2 = 580, 395
    @x_3, @y_3 = ($wndw_width - @b3_width)/2, 530
    @button_1_txt = Gosu::Image.from_text("Random Name", 20)#(text, height)
    @button_2_txt = Gosu::Image.from_text("Random Name", 20)
    @button_3_txt = Gosu::Image.from_text("Start Game", 20)
    @b1_txt_width, @b1_txt_height = @button_1_txt.width, @button_1_txt.height
    @b2_txt_width, @b2_txt_height = @button_2_txt.width, @button_2_txt.height
    @b3_txt_width, @b3_txt_height = @button_3_txt.width, @button_3_txt.height
    @sym_up = Gosu::Image.new("media/uparrow3.png", tileable: true)
    @sym_dwn = Gosu::Image.new("media/downarrow3.png", tileable: true)

    #player name prompts:
    @p1_prompt = Gosu::Image.from_text("PLAYER1:", 20)
    @p2_prompt = Gosu::Image.from_text("PLAYER2:", 20)

    @counter = 0
    $text_input = true
    @run_name_generator= false
    @name_chosen = false

    #play with AI?
    @ai = false
    @ai_selected = false
    #AI toggle:
    @ai_prompt = Gosu::Image.from_text("AI:", 20)
    @bx1_size = 27
    @bx2_size = 19
    @ai_box1_x1, @ai_box1_y1 = 70, 395
    @ai_box1_x2, @ai_box1_y2 = 70 + @bx1_size, 395
    @ai_box1_x3, @ai_box1_y3 = 70, 395 + @bx1_size
    @ai_box1_x4, @ai_box1_y4 = 70 + @bx1_size, 395 + @bx1_size
    #inner box (acts as a tick but its a square instead)
    @ai_box2_x1, @ai_box2_y1 = 74, 399
    @ai_box2_x2, @ai_box2_y2 = 74 + @bx2_size, 399
    @ai_box2_x3, @ai_box2_y3 = 74, 399 + @bx2_size
    @ai_box2_x4, @ai_box2_y4 = 74 + @bx2_size, 399 + @bx2_size

    #default symbols
    @symbol_arr = ["X", "O"]
    @p1_sym_index = 0
    @p2_sym_index = 1

  end

  def ai
    return @ai
  end

  def edit_tb1_text(text)
    if text.length <= @txt_length_max
      @tb1_text = text.upcase.split("")
    else
      self.text = @tb1_text.join("").upcase
    end
  end

  def edit_tb2_text(text)
    if text.length <= @txt_length_max
      @tb2_text = text.upcase.split("")
    else
      self.text = @tb2_text.join("").upcase

    end
  end

  def p1_name
    return @tb1_text.join("")
  end

  def p1_symbol
    return @symbol_arr[@p1_sym_index]
  end

  def p2_symbol
    return  @symbol_arr[@p2_sym_index]
  end

  def p2_name
    return @tb2_text.join("")
  end

  def update(mouse_x, mouse_y)
    @mouse_x, @mouse_y = mouse_x, mouse_y
    #TEXT BOXES
    if Gosu.button_down? Gosu::KB_ESCAPE
      # Escape key will not be 'eaten' by text fields; use for deselecting.
      if $text_input
        $text_input = false
      else
        close
      end
    elsif Gosu.button_down? Gosu::MS_LEFT
      # Mouse click: Select text field based on mouse position.
      if self.tb1_under_mouse?
        @tb1_color = ACTIVE_COLOR
        @tb2_color = INACTIVE_COLOR
        @tb1_selected = true
        @tb2_selected = false
        self.text = @tb1_text.join("")
      elsif self.tb2_under_mouse?
        @tb2_color = ACTIVE_COLOR
        @tb1_color = INACTIVE_COLOR
        @tb1_selected = false
        @tb2_selected = true
        self.text = @tb2_text.join("")
         #BUTTON 1 ACTION
      elsif self.under_mouse?(@mouse_x, @mouse_y, @x_1, @y_1, @b1_width, @b1_height)
        @tb1_selected = true
        @tb2_selected = false
        self.text = @tb1_text.join("")
        @run_name_generator = true
        @name_chosen = false
         #BUTTON 2 ACTION
      elsif self.under_mouse?(@mouse_x, @mouse_y, @x_2, @y_2, @b2_width, @b2_height)
        @tb2_selected = true
        @tb1_selected = false
        self.text = @tb2_text.join("")
        @run_name_generator = true
        @name_chosen = false
         #BUTTON 3 ACTION
      elsif self.under_mouse?(@mouse_x, @mouse_y, @x_3, @y_3, @b3_width, @b3_height)
        $gameplay_started = true
        $text_input = false
        #P1 UP ARROW
      elsif self.under_mouse?(@mouse_x, @mouse_y, @x1 + WIDTH + 10, @y_1 - 1, @sym_up.width, @sym_up.height)
        if @call_count < 1
          @p1_sym_index = (@p1_sym_index + 1) % 2
          @p2_sym_index = (@p2_sym_index + 1) % 2
        end
        @call_count += 1
        #P1 DOWN ARROW
      elsif self.under_mouse?(@mouse_x, @mouse_y, @x1 + WIDTH + 10, @y_1 + 15, @sym_dwn.width, @sym_dwn.height)
        if @call_count < 1
          @p1_sym_index = (@p1_sym_index - 1) % 2
          @p2_sym_index = (@p2_sym_index - 1) % 2
        end
        @call_count += 1
        #P2 UP ARROW
      elsif self.under_mouse?(@mouse_x, @mouse_y, @x1 + WIDTH + 10, @y_2 - 1, @sym_up.width, @sym_up.height)
        if @call_count < 1
          @p2_sym_index = (@p2_sym_index + 1) % 2
          @p1_sym_index = (@p1_sym_index + 1) % 2
        end
        @call_count += 1
        #P2 DOWN ARROW
      elsif self.under_mouse?(@mouse_x, @mouse_y, @x1 + WIDTH + 10, @y_2 + 15, @sym_dwn.width, @sym_dwn.height)
        if @call_count < 1
          @p2_sym_index = (@p2_sym_index - 1) % 2
          @p1_sym_index = (@p1_sym_index - 1) % 2
        end
        @call_count += 1
      elsif self.under_mouse?(@mouse_x, @mouse_y, @ai_box1_x1, @ai_box1_y1, @bx1_size, @bx1_size)
        if @call_count < 1
          @ai = !@ai
        end
        @call_count += 1
      else
        @tb1_color = INACTIVE_COLOR
        @tb2_color = INACTIVE_COLOR
        @tb1_selected = false
        @tb2_selected = false
      end
    else
      @call_count = 0 #counts the number of calls when button held down
    end

    if @run_name_generator
      self.text = self.name_generator
    end

    self.edit_tb1_text(self.text) if @tb1_selected
    self.edit_tb2_text(self.text) if @tb2_selected
  end

  def draw(mouse_x, mouse_y)

    @ms_x, @ms_y = mouse_x, mouse_y
    @cursor.draw(@ms_x - (@cursor.width/2) + 8, @ms_y - (@cursor.height/2) + 15, 3)

    @background_img.draw(0, 0, 0, 1.35, 1.35)
    @sym_up.draw(@x1 + WIDTH + 10, @y_1 - 1, 2, 0.07, 0.07)
    @sym_dwn.draw(@x1 + WIDTH + 10, @y_1 + 15, 2, 0.07, 0.07)
    @sym_up.draw(@x1 + WIDTH + 10, @y_2 - 1, 2, 0.07, 0.07)
    @sym_dwn.draw(@x1 + WIDTH + 10, @y_2 + 15, 2, 0.07, 0.07)

    #tb_1
    Gosu.draw_rect(@x1 - PADDING, @y1 - PADDING, WIDTH + 2 * PADDING, height + 2 * PADDING, @tb1_color, 1)
    #tb_2
    Gosu.draw_rect(@x2 - PADDING, @y2 - PADDING, WIDTH + 2 * PADDING, height + 2 * PADDING, @tb2_color, 1)

    if @tb1_selected
      pos_x = @x1 + FONT.text_width(@tb1_text.join(""))
      Gosu.draw_line(pos_x, @y1, CARET_COLOR, pos_x, @y1 + height, CARET_COLOR, 2)
    elsif @tb2_selected
      pos_x = @x2 + FONT.text_width(@tb2_text.join(""))
      Gosu.draw_line(pos_x, @y2, CARET_COLOR, pos_x, @y2 + height, CARET_COLOR, 2)
    end

    FONT.draw(@tb1_text.join(""), @x1, @y1, 1)
    FONT.draw(@tb2_text.join(""), @x2, @y2, 1)

    #Draw p1 & p2 prompts
    @p1_prompt.draw(@x1 - 100, @y1, 2, 1, 1, Gosu::Color::WHITE)
    @p2_prompt.draw(@x2 - 100, @y2, 2, 1, 1, Gosu::Color::WHITE)

    #Draw player symbols & backgrounds
    Gosu.draw_quad(@x_1 - 34, @y_1 + 2, Gosu::Color::WHITE, @x_1 - 7, @y_1 + 2, Gosu::Color::WHITE, @x_1 - 34, @y_1 + 29, Gosu::Color::WHITE, @x_1 - 7, @y_1 + 29, Gosu::Color::WHITE, 2)
    FONT.draw(self.p1_symbol, @x_1 - 27, @y_1 + 6, 2, 1, 1, Gosu::Color::BLACK)
    Gosu.draw_quad(@x_2 - 34, @y_2 + 2, Gosu::Color::WHITE, @x_2 - 7, @y_2 + 2, Gosu::Color::WHITE, @x_2 - 34, @y_2 + 29, Gosu::Color::WHITE, @x_2 - 7, @y_2 + 29, Gosu::Color::WHITE, 2)
    FONT.draw(self.p2_symbol, @x_2 - 27, @y_2 + 6, 2, 1, 1, Gosu::Color::BLACK)

    #Draw AI selection stuff
    @ai_prompt.draw(@ai_box1_x1 - @bx1_size - 2, @ai_box1_y1 + 4, 2, 1, 1, Gosu::Color::WHITE)
    Gosu.draw_quad(@ai_box1_x1, @ai_box1_y1, Gosu::Color::WHITE, @ai_box1_x2, @ai_box1_y2, Gosu::Color::WHITE, @ai_box1_x3, @ai_box1_y3, Gosu::Color::WHITE, @ai_box1_x4, @ai_box1_y4, Gosu::Color::WHITE, 2)
    if @ai
      Gosu.draw_quad(@ai_box2_x1, @ai_box2_y1, Gosu::Color::GREEN, @ai_box2_x2, @ai_box2_y2, Gosu::Color::GREEN, @ai_box2_x3, @ai_box2_y3, Gosu::Color::GREEN, @ai_box2_x4, @ai_box2_y4, Gosu::Color::GREEN, 2)
      Gosu.draw_line(@ai_box2_x1, @ai_box2_y1, Gosu::Color::RED, @ai_box2_x4, @ai_box2_y4, Gosu::Color::RED, 2)
      Gosu.draw_line(@ai_box2_x3, @ai_box2_y3, Gosu::Color::RED, @ai_box2_x2, @ai_box2_y2, Gosu::Color::RED, 2)
    end

    #Draw button backgrounds and text
    Gosu.draw_quad(@x_1, @y_1, Gosu::Color::BLUE, @x_1 + @b1_width, @y_1, Gosu::Color::BLUE, @x_1, @y_1 + @b1_height, Gosu::Color::BLUE, @x_1 + @b1_width, @y_1 + @b1_height, Gosu::Color::BLUE, 2)
    @button_1_txt.draw(@x_1 + (@b1_width - @b1_txt_width)/2, @y_1 + (@b1_height - @b1_txt_height)/2, 2, 1, 1)
    Gosu.draw_quad(@x_2, @y_2, Gosu::Color::BLUE, @x_2 + @b2_width, @y_2, Gosu::Color::BLUE, @x_2, @y_2 + @b2_height, Gosu::Color::BLUE, @x_2 + @b2_width, @y_2 + @b2_height, Gosu::Color::BLUE, 2)
    @button_2_txt.draw(@x_2 + (@b2_width - @b2_txt_width)/2, @y_2 + (@b2_height - @b2_txt_height)/2, 2, 1, 1)
    Gosu.draw_quad(@x_3, @y_3, Gosu::Color::BLUE, @x_3 + @b3_width, @y_3, Gosu::Color::BLUE, @x_3, @y_3 + @b3_height, Gosu::Color::BLUE, @x_3 + @b3_width, @y_3 + @b3_height , Gosu::Color::BLUE, 2)
    @button_3_txt.draw(@x_3 + (@b3_width - @b3_txt_width)/2, @y_3 + (@b3_height - @b3_txt_height)/2, 2, 1, 1)
  end

  def name_generator
    @counter += 1

    if @counter < 50 && !@name_chosen
      @vowels = ["A", "E", "I", "O", "U"]
      @consonants = []

      ("A".."Z").each{|letter|
        if @vowels.detect{|v| v == letter} == nil
          @consonants << letter
        end
      }

      @name = []
      @name_length = 6

      for i in 0..@name_length
        if i == 0 || i == 3 || i == 4
          @name << @consonants[rand(0..@consonants.length)]
        else
          @name << @vowels[rand(0..4)]
        end
      end

      @name_as_string = ""
      @name.each{|letter|
      @name_as_string += "#{letter}"}

      return @name_as_string

    else
      @counter = 0
      @name_chosen = true
      @run_name_generator = false
      return @name_as_string
    end
  end

  def height
    FONT.height
  end

  def under_mouse?(x, y, x1, y1, w, h)
    x > x1 && x < x1 + w && y > y1 && y < y1 + h
  end

  def tb1_under_mouse?
    @mouse_x > @x1 - PADDING and @mouse_x < @x1 + WIDTH + PADDING and
      @mouse_y > @y1 - PADDING and @mouse_y < @y1 + height + PADDING
  end

  def tb2_under_mouse?
    @mouse_x > @x2 - PADDING and @mouse_x < @x2 + WIDTH + PADDING and
      @mouse_y > @y2 - PADDING and @mouse_y < @y2 + height + PADDING
  end
end

#---------------------------------------------------

class GameplayScene

  def initialize(p1_name, p1_symbol, p2_name, p2_symbol, ai)
    @cursor = Gosu::Image.new("media/cursor.png", tileable: true) #Custom Cursor
    @background_img = Gosu::Image.new("media/dark_wood_bg.jpg", tileable: true)
    @board_image = Gosu::Image.new("media/thegrid.png", tileable: true) #background image
    @tie_txt = Gosu::Image.from_text("ITS A DRAW!", 50)

    @p1_symbol = p1_symbol
    @p2_symbol = p2_symbol
    @p1_name = p1_name
    @p2_name = p2_name

    #AI
    @ai = ai
    @ai_turn = false

    if @p1_name == ""
      @p1_turn = Gosu::Image.from_text("#{p1_symbol}'S TURN!", 50)
      if @ai
        @p1_win_txt = Gosu::Image.from_text("YOU WIN!", 50)
      else
        @p1_win_txt = Gosu::Image.from_text("#{p1_symbol} WINS!", 50)
      end
    else
      @p1_turn = Gosu::Image.from_text("#{p1_name.upcase}'S TURN!", 50)
      if @ai
        @p1_win_txt = Gosu::Image.from_text("YOU WIN!", 50)
      else
        @p1_win_txt = Gosu::Image.from_text("#{p1_name.upcase} WINS!", 50)
      end
    end

    if @p2_name == ""
      @p2_turn = Gosu::Image.from_text("#{p2_symbol}'S TURN!", 50)
      if @ai
        @p2_win_txt = Gosu::Image.from_text("YOU LOSE!", 50)
      else
        @p2_win_txt = Gosu::Image.from_text("#{p2_symbol} WINS!", 50)
      end
    else
      @p2_turn = Gosu::Image.from_text("#{p2_name.upcase}'S TURN!", 50)
      if @ai
        @p2_win_txt = Gosu::Image.from_text("YOU LOSE!", 50)
      else
        @p2_win_txt = Gosu::Image.from_text("#{p2_name.upcase} WINS!", 50)
      end
    end

    @moves = 0
    @tie = false
    @counter = 0
    @counter2 = 0

    if @p1_symbol == "X"
      @p1 = Cross.new
      @p2 = Naught.new
      @win = [$cross_win, $naught_win]
      @p1_img = Gosu::Image.new("media/smallcross.png", tileable: true)
      @p2_img = Gosu::Image.new("media/smallcircle.png", tileable: true)
    else
      @p1 = Naught.new
      @p2 = Cross.new
      @win = [$naught_win, $cross_win]
      @p1_img = Gosu::Image.new("media/smallcircle.png", tileable: true)
      @p2_img = Gosu::Image.new("media/smallcross.png", tileable: true)
    end

    @all_grid_indices = []
  end

  def update(x, y)
    @x, @y = x, y

    if @moves.odd? && @ai
      @ai_turn = true
    else
      @ai_turn = false
    end

    if @moves.even? && (Gosu.button_down? Gosu::MS_LEFT)
      if @counter == 0
        @p1.new_coord(@x, @y, @all_grid_indices)
        @p1.count
        @p1.win_check if @moves > 2
        @all_grid_indices << @p1.last_index if @p1.allowed_move?
        @moves += 1 if @p1.allowed_move?
        @counter += 1
      end
    elsif @moves.even? && !(Gosu.button_down? Gosu::MS_LEFT)
      @counter = 0
    elsif @ai_turn
      unless $ai_moving_to_target
        @p2.count
        @all_grid_indices << @p2.last_index #if @p2.allowed_move?
        @p2.win_check if @moves > 2
        @moves += 1 if @p2.allowed_move?
      end
      @counter = 0
    elsif (Gosu.button_down? Gosu::MS_LEFT) && !@ai
      if @counter == 0
        @p2.new_coord(@x, @y, @all_grid_indices)
        @p2.count
        @all_grid_indices << @p2.last_index if @p2.allowed_move?
        @p2.win_check if @moves > 2
        @moves += 1 if @p2.allowed_move?
        @counter += 1
      end
    else
      @counter = 0
    end

    if @moves > 8
      $tie = true
      if @counter2 > 50
        $new_board = true
        $tie = false
        @counter2 = 0
      end
      @counter2 += 1
    end

    if $new_board == true
      @all_grid_indices = []
      @p1.wipe_board
      @p2.wipe_board
      $new_board = false
      $cross_win = false
      $naught_win = false
      @moves = 0
    end

    if @p1_symbol == "X"
      @win = [$cross_win, $naught_win]
    else
      @win = [$naught_win, $cross_win]
    end
  end

  def draw(mouse_x, mouse_y)

    @background_img.draw(0, 0, 0, 1.35, 1.35)

    @board_image.draw($board_x, $board_y, 0)

    @ms_x, @ms_y = mouse_x, mouse_y

    if @moves.odd? && @ai
      @ai_turn = true
    else
      @ai_turn = false
    end

    unless @ai_turn
      @cursor.draw(@ms_x - (@cursor.width/2) + 8, @ms_y - (@cursor.height/2) + 15, 3)
    end

    @p1.draw
    @p2.draw

    if @win[0]
      @p1.strike_through
      @p1_win_txt.draw(($wndw_width - @p1_win_txt.width)/2, 1, 6, 1, 1)
    elsif @win[1]
      @p2.strike_through
      @p2_win_txt.draw(($wndw_width - @p2_win_txt.width)/2, 1, 6, 1, 1)
    else
      if @moves.even? && !$tie
        @p1_turn.draw(($wndw_width - @p1_turn.width)/2, 1, 6, 1, 1)
      elsif @moves.odd? && !$tie
        if @ai
          @p2.ai_take_turn(@ms_x, @ms_y, @cursor, @all_grid_indices)
        end
        @p2_turn.draw(($wndw_width - @p2_turn.width)/2, 1, 6, 1, 1)
      else
        @tie_txt.draw(($wndw_width - @tie_txt.width)/2, 1, 6, 1, 1)
      end
    end
  end

end

#---------------------------------------------------

class Naught

  include DrawingTools

  def initialize
    @image = Gosu::Image.new("media/smallcircle.png", tileable: true)
    @image_height = @image.height
    @image_width = @image.width

    @f_x = 0.5 #image width scale factor
    @f_y = 0.5 #image hiaght scale factor

    @count = 0

    @occupied_grid_coords = Array.new
    @occupied_grid_indices = Array.new
    @grid_indices = Array.new

    @tile_height = $board_height / 3

    @y1 = $board_y + @tile_height
    @y2 = $board_y + 2 * @tile_height
    @y3 = $board_y + $board_height

    @tile_width = $board_width / 3

    @x1 = $board_x + @tile_width
    @x2 = $board_x + 2 * @tile_width
    @x3 = $board_x + $board_width

    @index_to_grid = Hash.new #maps grid index (row, column) to grid coords
    @grid_to_index = Hash.new #maps grid coords to their respective index

    for r in 1..3 # creates the above hashes
      @y_pos = $board_y + ((r - 0.5) * @tile_height)
      for c in 1..3
        @x_pos = $board_x + ((c - 0.5) * @tile_width)
        @index_to_grid.store([r, c], [@x_pos, @y_pos])
        @grid_to_index.store([@x_pos, @y_pos], [r, c])
        @grid_indices << [r, c]
      end
    end

    @length = 0 #for strike through
    @segment_no = 0 #for strike through
  end

  def image
    return @image
  end


  def get_index(x, y)
    @x, @y = x, y
    @index = Array.new

    # | MAKE THIS INTO ITS OWN SEPERATE FUNCTION MODULE
    # V

    if @x > $board_x && @x < @x1
      @index[1] = 1
    elsif x > @x1 && x < @x2
      @index[1] = 2
    elsif @x > @x2 && @x < @x3
      @index[1] = 3
    end

    if @y > $board_y && @y < @y1
      @index[0] = 1
    elsif @y > @y1 && @y < @y2
      @index[0] = 2
    elsif @y > @y2 && @y < @y3
      @index[0] = 3
    end

    return @index
  end


  def allowed_move?
    return @allowed_move
  end


  def wipe_board
    @occupied_grid_coords = []
    @occupied_grid_indices = []
    @count = 0
  end

  def last_index
    return @occupied_grid_indices[@occupied_grid_indices.length - 1]
  end


  def new_coord(x, y, all_grid_indices)
    if !all_grid_indices.include?(get_index(x, y)) && !$naught_win && !$cross_win
      @occupied_grid_coords << @index_to_grid[get_index(x, y)]
      @occupied_grid_indices << get_index(x, y)
      self.count
      @allowed_move = true
    else
      @allowed_move = false
    end
  end

  def win?
    return $naught_win
  end

  def ai_take_turn(mouse_x, mouse_y, cursor, all_grid_indices) #This method is called in draw

    @allowed_move = true unless $naught_win || $cross_win || $tie

    @ms_x, @ms_y = mouse_x, mouse_y if !$ai_moving_to_target
    @cursor = cursor

    @available_grid_indices = Array.new
    @grid_indices.each{ |i|
      if !all_grid_indices.include?(i)
        @available_grid_indices << i
      end
      }

      @agi_lgth = @available_grid_indices.length

    if $ai_moving_to_target != true
      @target_index = @available_grid_indices[rand(0...@agi_lgth)]
      @target_x = @index_to_grid[@target_index][0]
      @target_y = @index_to_grid[@target_index][1]

      @x, @y = @ms_x, @ms_y

      @delta_x = @target_x - @ms_x
      @delta_y = @target_y - @ms_y

      if @delta_x < 0
        @x_axis = -1 #flip axis
      else
        @x_axis = 1
      end

      if @delta_y < 0
        @y_axis = -1 #flip axis
      else
        @y_axis = 1
      end

      @tan_of_angle = @delta_y / @delta_x
      @angle = Math.atan(@tan_of_angle.abs)

      @vel = 5 #pixels/frame
      @vel_x = @x_axis * @vel * Math.cos(@angle) #pixels/frame
      @vel_y = @y_axis * @vel * Math.sin(@angle) #pixels/frame

      $ai_moving_to_target = true
      @cursor.draw(@x - (@cursor.width/2) + 8, @y - (@cursor.height/2) + 15, 3)
    elsif @x < @target_x + 5 && @x > @target_x - 5 && @y < @target_y + 5 && @y > @target_y - 5
      @occupied_grid_indices << @target_index
      @occupied_grid_coords << [@target_x, @target_y]
      $ai_moving_to_target = false
    else
      @x += @vel_x
      @y += @vel_y
      @cursor.draw(@x - (@cursor.width/2) + 8, @y - (@cursor.height/2) + 15, 3)
      $ai_moving_to_target = true
    end
  end

  def count
    @count += 1
  end

  def draw
    @occupied_grid_coords.each{
      |coord|

    self.draw_and_centre(@image, coord[0], coord[1], 1, @f_x, @f_y)
  }
  end

  def win_check
    @row_count = [0, 0, 0]
    @row_match = false
    @col_count = [0, 0, 0]
    @col_match = false
    @diag1_count = 0
    @diag2_count = 0

    @occupied_grid_indices.each{ |index|

      for i in 1..3

        if index == [i, i]
          @diag1_count += 1
        end

        if index == [i, 4-i]
          @diag2_count += 1
        end

        for j in 1..3

          if index == [i, j]
            @row_count[i - 1] += 1
          end

          if index == [j, i]
            @col_count[i - 1] += 1
          end

        end

      end

     }

     @row_count.each{|count| @row_match = true if count > 2}
     @col_count.each{|count| @col_match = true if count > 2}

     if @row_match || @col_match || @diag1_count > 2 || @diag2_count > 2
       puts "Naughts win!" unless $naught_win == true
       $naught_win = true
       @allowed_move = false
     end
   end

   def strike_through

     #KEEP DRAWING?

     if @segment_no == @max_segment_no
       @drawing_complete = true #IF TRUE #YES
       $new_board = true
       @length = 0
       @segment_no = 0
     else
       @drawing_complete = false #ELSE #NO
     end

     #ROW & COLUMN STRIKE

     for i in 0..2

       if @row_count[i] > 2 && @drawing_complete == false

         @x_inc = 8
         @y_inc = 0
         @segment_length = Math.sqrt(@x_inc**2 + @y_inc**2)

         @length += @segment_length
         @segment_no += 1

         @total_length = $board_width
         @max_segment_no = (@total_length / @segment_length).round

         @start_x = $board_x
         @start_y = @index_to_grid[[i+1,1]][1]

         @Cx = 0
         @Cy = 1

         break

       elsif @col_count[i] > 2 && @drawing_complete == false

           @x_inc = 0
           @y_inc = 8
           @segment_length = Math.sqrt(@x_inc**2 + @y_inc**2)

           @length += @segment_length
           @segment_no += 1

           @total_length = $board_height
           @max_segment_no = (@total_length / @segment_length).round

           @start_x = @index_to_grid[[1,i+1]][0]
           @start_y = $board_y

           @Cx = 1 #without this being different for columns, lines wont draw properly
           @Cy = 0

           break

       end

     end

     #DIAGONALS STRIKE

     if @diag1_count > 2 && @drawing_complete == false

       @x_inc = 8
       @y_inc = 8
       @segment_length = Math.sqrt(@x_inc**2 + @y_inc**2)

       @length += @segment_length
       @segment_no += 1

       @total_length = Math.sqrt($board_width**2 + $board_height**2)
       @max_segment_no = (@total_length / @segment_length).round

       @start_x = $board_x
       @start_y = $board_y

       @Cx = 0
       @Cy = 1

     elsif @diag2_count > 2 && @drawing_complete == false

         @x_inc = 8
         @y_inc = -8
         @segment_length = Math.sqrt(@x_inc**2 + @y_inc**2)

         @length += @segment_length
         @segment_no += 1

         @total_length = Math.sqrt($board_width**2 + $board_height**2)
         @max_segment_no = (@total_length / @segment_length).round

         @start_x = $board_x
         @start_y = $botright_y

         @Cx = 0
         @Cy = 1

     end

     #EACH FRAME INCREASES END COORDINATES OF LINE BY GIVEN INCREMENTS

      @end_x = @start_x + (@segment_no * @x_inc)
      @end_y = @start_y + (@segment_no * @y_inc)

      Gosu.draw_quad(@start_x, @start_y, Gosu::Color::RED, @end_x, @end_y, Gosu::Color::RED, @end_x + (@Cx*6), @end_y + (@Cy*6), Gosu::Color::RED, @start_x + (@Cx*6), @start_y + (@Cy*6), 6)
   end

end

#---------------------------------------------------

class Cross

  include DrawingTools

  def initialize

    @image = Gosu::Image.new("media/smallcross.png", tileable: true)
    @image_height = @image.height
    @image_width = @image.width

    @count = 0

    @f_x = 0.5 #image width scale-factor
    @f_y = 0.5 #image height scale-factor

    @occupied_grid_coords = Array.new
    @occupied_grid_indices = Array.new
    @grid_indices = Array.new

    @tile_height = $board_height / 3

    @y1 = $board_y + @tile_height
    @y2 = $board_y + 2 * @tile_height
    @y3 = $board_y + $board_height

    @tile_width = $board_width / 3

    @x1 = $board_x + @tile_width
    @x2 = $board_x + 2 * @tile_width
    @x3 = $board_x + $board_width

    @index_to_grid = Hash.new #maps grid index (row, column) to grid coords
    @grid_to_index = Hash.new #maps grid coords to their respective index

    for r in 1..3 # creates the above hashes
      @y_pos = $board_y + ((r - 0.5) * @tile_height)
      for c in 1..3
        @x_pos = $board_x + ((c - 0.5) * @tile_width)
        @index_to_grid.store([r, c], [@x_pos, @y_pos])
        @grid_to_index.store([@x_pos, @y_pos], [r, c])
        @grid_indices << [r, c]
      end
    end

    @length = 0
    @segment_no = 0

  end

  def image
    return @image
  end

  def get_index(x, y)

    @x, @y = x, y
    @index = Array.new

    if @x > $board_x && @x < @x1
      @index[1] = 1
    elsif x > @x1 && x < @x2
      @index[1] = 2
    elsif @x > @x2 && @x < @x3
      @index[1] = 3
    end

    if @y > $board_y && @y < @y1
      @index[0] = 1
    elsif @y > @y1 && @y < @y2
      @index[0] = 2
    elsif @y > @y2 && @y < @y3
      @index[0] = 3
    end

    return @index

  end

  def wipe_board
    @occupied_grid_coords = []
    @occupied_grid_indices = []
    @count = 0
  end

  def last_index
    return @occupied_grid_indices[@occupied_grid_indices.length - 1]
  end

  def allowed_move?
    return @allowed_move
  end

  def new_coord(x, y, all_grid_indices)
    if !all_grid_indices.include?(get_index(x, y)) && !$cross_win && !$naught_win
      @occupied_grid_coords << @index_to_grid[get_index(x, y)]
      @occupied_grid_indices << get_index(x, y)
      self.count
      @allowed_move = true
    else
      @allowed_move = false
    end
  end

  def win?
    return $cross_win
  end

  def ai_take_turn(mouse_x, mouse_y, cursor, all_grid_indices) #This method is called in draw

    @allowed_move = true unless $naught_win || $cross_win || $tie

    @ms_x, @ms_y = mouse_x, mouse_y if !$ai_moving_to_target
    @cursor = cursor

    @available_grid_indices = Array.new
    @grid_indices.each{ |i|
      if !all_grid_indices.include?(i)
        @available_grid_indices << i
      end
      }

      @agi_lgth = @available_grid_indices.length

    if $ai_moving_to_target != true
      @target_index = @available_grid_indices[rand(0...@agi_lgth)]
      @target_x = @index_to_grid[@target_index][0]

      @x, @y = @ms_x, @ms_y

      @delta_x = @target_x - @ms_x
      @delta_y = @target_y - @ms_y

      if @delta_x < 0
        @x_axis = -1 #flip axis
      else
        @x_axis = 1
      end

      if @delta_y < 0
        @y_axis = -1 #flip axis
      else
        @y_axis = 1
      end

      @tan_of_angle = @delta_y / @delta_x
      @angle = Math.atan(@tan_of_angle.abs)

      @vel = 5 #pixels/frame
      @vel_x = @x_axis * @vel * Math.cos(@angle) #pixels/frame
      @vel_y = @y_axis * @vel * Math.sin(@angle) #pixels/frame

      $ai_moving_to_target = true
      @cursor.draw(@x - (@cursor.width/2) + 8, @y - (@cursor.height/2) + 15, 3)
    elsif @x < @target_x + 5 && @x > @target_x - 5 && @y < @target_y + 5 && @y > @target_y - 5
      @occupied_grid_indices << @target_index
      @occupied_grid_coords << [@target_x, @target_y]
      $ai_moving_to_target = false
    else
      @x += @vel_x
      @y += @vel_y
      @cursor.draw(@x - (@cursor.width/2) + 8, @y - (@cursor.height/2) + 15, 3)
      $ai_moving_to_target = true
    end
  end

  def count
    @count += 1
  end

  def draw

    @occupied_grid_coords.each{
      |coord|

    self.draw_and_centre(@image, coord[0], coord[1], 1, @f_x, @f_y)

  }



  end

  def win_check

    @row_count = [0, 0, 0]
    @row_match = false
    @col_count = [0, 0, 0]
    @col_match = false
    @diag1_count = 0
    @diag2_count = 0

    @occupied_grid_indices.each{ |index|

      for i in 1..3

        if index == [i, i]
          @diag1_count += 1
        end

        if index == [i, 4-i]
          @diag2_count += 1
        end

        for j in 1..3

          if index == [i, j]
            @row_count[i - 1] += 1
          end

          if index == [j, i]
            @col_count[i - 1] += 1
          end

        end

      end

     }

     @row_count.each{|count| @row_match = true if count > 2 }
     @col_count.each{|count| @col_match = true if count > 2}

     if @row_match || @col_match || @diag1_count > 2 || @diag2_count > 2
       puts "Crosses win!" unless $cross_win == true
       $cross_win = true
     end
  end

  def strike_through

     #KEEP DRAWING?

     if @segment_no == @max_segment_no
       @drawing_complete = true
       $new_board = true
       @length = 0
       @segment_no = 0
     else
       @drawing_complete = false
     end

     #ROW & COLUMN STRIKE

     for i in 0..2

       if @row_count[i] > 2 && @drawing_complete == false

         @x_inc = 8
         @y_inc = 0
         @segment_length = Math.sqrt(@x_inc**2 + @y_inc**2)

         @length += @segment_length
         @segment_no += 1

         @total_length = $board_width
         @max_segment_no = (@total_length / @segment_length).round

         @start_x = $board_x
         @start_y = @index_to_grid[[i+1,1]][1]

         @Cx = 0
         @Cy = 1

         break

       elsif @col_count[i] > 2 && @drawing_complete == false

           @x_inc = 0
           @y_inc = 8
           @segment_length = Math.sqrt(@x_inc**2 + @y_inc**2)

           @length += @segment_length
           @segment_no += 1

           @total_length = $board_height
           @max_segment_no = (@total_length / @segment_length).round

           @start_x = @index_to_grid[[1,i+1]][0]
           @start_y = $board_y

           @Cx = 1 #different for columns
           @Cy = 0

           break

       end

     end

     #DIAGONALS STRIKE

     if @diag1_count > 2 && @drawing_complete == false

       @x_inc = 8
       @y_inc = 8
       @segment_length = Math.sqrt(@x_inc**2 + @y_inc**2)

       @length += @segment_length
       @segment_no += 1

       @total_length = Math.sqrt($board_width**2 + $board_height**2)
       @max_segment_no = (@total_length / @segment_length).round

       @start_x = $board_x
       @start_y = $board_y

       @Cx = 0
       @Cy = 1

     elsif @diag2_count > 2 && @drawing_complete == false

         @x_inc = 8
         @y_inc = -8
         @segment_length = Math.sqrt(@x_inc**2 + @y_inc**2)

         @length += @segment_length
         @segment_no += 1

         @total_length = Math.sqrt($board_width**2 + $board_height**2)
         @max_segment_no = (@total_length / @segment_length).round

         @start_x = $board_x
         @start_y = $botright_y

         @Cx = 0
         @Cy = 1

     end

     #EACH FRAME INCREASES END COORDINATES OF LINE BY GIVEN INCREMENTS

         @end_x = @start_x + (@segment_no * @x_inc)
         @end_y = @start_y + (@segment_no * @y_inc)

         #puts "#{@start_x}, #{@start_y}, #{@end_x}, #{@end_y}"

        Gosu.draw_quad(@start_x, @start_y, Gosu::Color::RED, @end_x, @end_y, Gosu::Color::RED, @end_x + (@Cx*6), @end_y + (@Cy*6), Gosu::Color::RED, @start_x + (@Cx*6), @start_y + (@Cy*6), 6)

  end

end

#---------------------------------------------------

class Game < Gosu::Window

  def initialize
    super($wndw_width, $wndw_height, false) #sets window size
    self.caption = "Naughts And Crosses" #sets window caption

    #Loading Screen
    @loading_txt = Gosu::Image.from_text("LOADING...", 50)
    @loading_text = Gosu::Font.new(50)
    @loading_count = 0

    @main_menu = MainMenuScene.new
    self.text_input = @main_menu
  end

  def update
    @p1_name = @main_menu.p1_name
    @p1_symbol = @main_menu.p1_symbol
    @p2_name = @main_menu.p2_name
    @p2_symbol = @main_menu.p2_symbol

    if !$text_input
      self.text_input = nil
    end

    if $gameplay_started && $gameplay_loaded
      @gameplay.update(self.mouse_x, self.mouse_y)
    elsif $gameplay_started && !$gameplay_loaded
      if (Gosu.milliseconds % 500) < 20
        @loading_count += 1
      end
      if @loading_count > 10
        @gameplay = GameplayScene.new(@p1_name, @p1_symbol, @p2_name, @p2_symbol, @main_menu.ai)
        $gameplay_loaded = true
      end
    else
      @main_menu.update(self.mouse_x, self.mouse_y)
    end
  end

  def draw
    if $gameplay_started && $gameplay_loaded
      @gameplay.draw(self.mouse_x, self.mouse_y)
    elsif $gameplay_started && !$gameplay_loaded
      @n = @loading_count % 4
      @loading_dots = Array.new(@n, ".").join("")
      @loading_text.draw("LOADING#{@loading_dots}", 240, $wndw_height/2 - 40, 1)
    else
      @main_menu.draw(self.mouse_x, self.mouse_y)
    end
  end

end

#===================================================

Game.new.show
