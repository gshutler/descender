require 'canyon_descender_outputter'

class CanyonDescender
  include CanyonDescenderOutputter

  DEFAULT_STARTING_FUEL = 10

  def initialize(params = {})
    @starting_fuel = params[:fuel] || DEFAULT_STARTING_FUEL
  end
  
  def descend(canyon, starting_depth)
    @canyon = canyon
    @position = {:row => starting_depth, :col => 0}
    @crashed = false
    @remaining_fuel = @starting_fuel
    @path_taken = []
  end
    
  def next_action
    navigate_canyon unless can_see_bottom?
    update_descender_state
    record_position
  end
  
  def finished?
    @position[:row]+1 == @canyon.length or @crashed
  end
  
  private

  def record_position
    @path_taken << {:row => @position[:row], :col => @position[:col], :boosting => @boosting}
  end
    
  def update_descender_state
    @remaining_fuel -= 1 if @boosting
    @position[:row] += 1 unless @boosting
    
    @crashed = true unless @canyon[@position[:row]][@position[:col]]
  end  
  
  def navigate_canyon
    if space_beneath > space_to_right or space_beneath > space_to_left
      move_right if gap_to_right? and space_beneath_right >= space_beneath
      move_left if gap_to_left? and space_beneath_left >= space_beneath
    else
      if space_to_right == space_to_left
        move_right if gap_to_right?
        move_left if gap_to_left?
      else
        move_right if space_to_right > space_to_left and can_move_right?
        move_left if space_to_left > space_to_right and can_move_left?
      end
    end
    
    @boosting = should_boost?
  end
  
  def move_right
    @position[:col] += 1
  end
  
  def move_left
    @position[:col] -= 1
  end
  
  def gap_to_right?
    row = obstacle_depth
    col = @position[:col]+1    
    while col < @canyon[0].length
      return true if @canyon[row][col]
      col += 1
    end
    false
  end
  
  def gap_to_left?
    not gap_to_right?
  end
  
  def count_until(params)
    row, col = params[:start]
    count = 0
    until params[:pred].call(row, col)
      row, col = params[:inc].call(row, col)
      count += 1
    end
    count
  end
  
  def obstacle_depth
    pred = lambda do |row, col| 
      row == @canyon.length - 1 or not @canyon[row][col]
    end
    
    inc = lambda do |row, col| 
      [row+1, col]
    end
    
    count = count_until :pred => pred, :start => [@position[:row]+1, @position[:col]], :inc => inc
    
    @position[:row] + count + 1
  end
  
  def can_see_bottom?
    obstacle_depth == @canyon.length-1
  end
  
  def space_to_right
    row = @position[:row]+1
    col = @position[:col]+1
    space = 0
    while row < @canyon.length and col < @canyon[0].length and @canyon[row][col] 
      space += 1
      row += 1
      col += 1
    end
    space
  end
  
  def space_beneath
    row = @position[:row]+1
    space = 0
    while row < @canyon.length and @canyon[row][@position[:col]]
      space += 1
      row += 1
    end
    space
  end
  
  def space_beneath_left
    return 0 unless can_move_left?
    row = @position[:row]+1
    col = @position[:col]-1
    space = 0
    while row < @canyon.length and @canyon[row][col]
      space += 1
      row += 1
    end
    space
  end
  
  def space_beneath_right
    return 0 unless can_move_right?
    row = @position[:row]+1
    col = @position[:col]+1
    space = 0
    while row < @canyon.length and @canyon[row][col]
      space += 1
      row += 1
    end
    space
  end
  
  def space_to_left
    row = @position[:row]+1
    col = @position[:col]-1
    space = 0
    while row < @canyon.length and col >=0 and @canyon[row][col] 
      space += 1
      row += 1
      col -= 1
    end
    space
  end
    
  def should_boost?
    can_boost? and @canyon[@position[:row]+1][@position[:col]] == false
  end
  
  def can_move_left?
    @position[:col] > 0
  end
  
  def can_move_right?
    @position[:col]+1 < @canyon.length
  end
  
  def can_boost?
    @remaining_fuel > 0
  end

end
