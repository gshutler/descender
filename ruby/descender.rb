require 'canyon_generator'
require 'canyon_descender'

CLEAR_SCREEN_CODE = "\e[H\e[2J"

def clear_screen
  print CLEAR_SCREEN_CODE
end

generator = CanyonGenerator.new(:width => 30, :depth => 100, :min_overlap => 6)
canyon = generator.generate

@descender = CanyonDescender.new(:fuel => 20)
@descender.descend canyon, 30

def print_rows(rows)
  rows.each do |row|
    puts "|#{row}|"
  end
end

FRAME_HEIGHT = 35
@frame = 0
PLAYING = true

def display_descent
  if PLAYING
    frame_display = @descender.descent_state.slice(@frame, FRAME_HEIGHT)
    
    clear_screen
    print_rows frame_display
    sleep 0.1
  end
end

until @descender.finished?
  
  display_descent
  
  @frame += 1
  @descender.next_action
  
end

display_descent

puts "Survived #{@frame} moves"
print_rows @descender.descent_history unless PLAYING
