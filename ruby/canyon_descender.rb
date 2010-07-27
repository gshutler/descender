require 'canyon_descender_outputter'

class CanyonDescender
  include CanyonDescenderOutputter

  DEFAULT_STARTING_BOOSTS = 10
  
  attr_reader :remaining_boosts, :crashed, :path_taken

  def initialize(params = {})
    @starting_boosts = params[:boosts] || DEFAULT_STARTING_BOOSTS
  end
  
  def descend(canyon, starting_depth)
    @canyon = canyon
    @position = {:row => starting_depth, :col => 0}
    @crashed = false
    @remaining_boosts = @starting_boosts
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
  
  def navigate_canyon
    move_right if gap_to_right? and space_beneath_right >= space_beneath
    move_left if gap_to_left? and space_beneath_left >= space_beneath
        
    @boosting = should_boost?
  end
  
  def update_descender_state
    @remaining_boosts -= 1 if @boosting
    @position[:row] += 1 unless @boosting
    
    @crashed = true unless @canyon[@position[:row]][@position[:col]]
  end
  
  def record_position
    row, col = @position[:row], @position[:col]
    @path_taken << {:row => row, :col => col, :boosting => @boosting, :crashed => @crashed}
  end
    
  def move_right
    @position[:col] += 1
  end
  
  def move_left
    @position[:col] -= 1
  end
  
  def gap_to_right?
    return false if can_see_bottom?
    row = obstacle_depth
    col = @position[:col] + 1
    while row < @canyon.length and col < @canyon[0].length
      return true if @canyon[row][col]
      col += 1
    end
    false
  end
  
  def gap_to_left?
    not gap_to_right? unless can_see_bottom?
  end
      
  def obstacle_depth
    @position[:row] + space_beneath + 1
  end
  
  def can_see_bottom?
    obstacle_depth == @canyon.length
  end
  
  def space_beneath
    space_beneath_when
  end
  
  def space_beneath_left
    space_beneath_when :offset => -1, :possible => can_move_left?
  end
  
  def space_beneath_right
    space_beneath_when :offset => 1, :possible => can_move_right?
  end
  
  def space_beneath_when(params = {})
    offset = params[:offset] || 0
    possible = params[:possible] || true
    
    count_while :row_inc => 1, :col_offset => offset do |row, col|
      possible and row < @canyon.length and @canyon[row][col]
    end
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
    @remaining_boosts > 0
  end
  
  def count_while(params, &b)
    row_inc = params[:row_inc] || 0
    col_inc = params[:col_inc] || 0
    
    if params[:row_offset].nil?
      row = @position[:row] + row_inc
    else
      row = @position[:row] + params[:row_offset]
    end
    
    if params[:col_offset].nil?
      col = @position[:col] + col_inc
    else
      col = @position[:col] + params[:col_offset]
    end
        
    count = 0
    
    while yield(row, col)
      row = row + row_inc
      col = col + col_inc
      count += 1
    end
    
    count
  end
  
end
