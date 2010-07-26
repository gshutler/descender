require 'yaml'

class CanyonGenerator

  DEFAULT_CANYON_WIDTH = 20
  DEFAULT_CANYON_DEPTH = 20
  DEFAULT_MINIMUM_OVERLAP = 5

  def initialize(params = {})
    @canyon_width = params[:width] || DEFAULT_CANYON_WIDTH
    @canyon_depth = params[:depth] || DEFAULT_CANYON_DEPTH
    @minimum_overlap = params[:min_overlap] || DEFAULT_MINIMUM_OVERLAP
  end

  def generate(canyon_width = DEFAULT_CANYON_WIDTH, canyon_depth = DEFAULT_CANYON_DEPTH)
    rows = []
    last_row = as_boolean_array(:start => 0, :width => @canyon_width)

    # add a starting section to get the descender going
    pad_canyon rows, @canyon_width*2

    @canyon_depth.times do
      # reset row definition to always fail first evaluation
      potential_row = as_boolean_array(:start => 0, :width => 0)
      until correct_size potential_row and enough_overlap potential_row, last_row
        potential_row = random_row
      end
      
      rows << potential_row  
      last_row = potential_row
    end
    
    # add a blank section for the descender to reach
    pad_canyon rows, @canyon_width
  end
  
  private
  
  def pad_canyon(rows, amount)
    amount.times do
      rows << as_boolean_array(:start => 0, :width => @canyon_width)
    end
    rows
  end
  
  def random_row
    as_boolean_array(:start => Kernel.rand(@canyon_width), :width => Kernel.rand(@canyon_width))
  end
  
  def as_boolean_array(rowdef)
    row = []
        
    rowdef[:start].times do
      row << false
    end
    
    rowdef[:width].times do
      row << true
    end

    (@canyon_width - row.length).times do
      row << false
    end
    
    row
  end

  def enough_overlap(potential_row, last_row)
    overlapping = 0
    
    potential_row.each_index do |index|
      overlapping += 1 if potential_row[index] and last_row[index]
    end
    
    overlapping >= @minimum_overlap
  end
  
  def correct_size(row)
    row.length == @canyon_width
  end
end

if __FILE__ == $0

  def print_rows(rows)
    rows.each do |row|
      puts "|#{row.map {|x| x ? ' ' : '#'}}|"
    end
  end


  print_rows(CanyonGenerator::generate)
end
