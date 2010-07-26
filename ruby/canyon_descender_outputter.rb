module CanyonDescenderOutputter

  def descent_state
    canyon_display = @canyon.map do |row|
      row.map {|col| col ? ' ' : '#'}
    end
    if @canyon[@position[:row]][@position[:col]]
      canyon_display[@position[:row]][@position[:col]] = 'V'
    else
      canyon_display[@position[:row]][@position[:col]] = '@'
    end
    canyon_display[@position[:row]+1][@position[:col]] = '*' if @boosting
    canyon_display
  end
  
  def descent_history
    canyon_display = @canyon.map do |row|
      row.map {|col| col ? ' ' : '#'}
    end
    @path_taken.each do |path|
      canyon_display[path[:row]][path[:col]] = 'V'
      canyon_display[path[:row]+1][path[:col]] = '*' if path[:boosting]
    end
    canyon_display
  end

end
