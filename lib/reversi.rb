class Reversi
  attr_accessor :board

  def initialize
    n = nil
    b = true
    w = false

    @board = [
      [n,n,n,n,n,n,n,n],
      [n,n,n,n,n,n,n,n],
      [n,n,n,n,n,n,n,n],
      [n,n,n,w,b,n,n,n],
      [n,n,n,b,w,n,n,n],
      [n,n,n,n,n,n,n,n],
      [n,n,n,n,n,n,n,n],
      [n,n,n,n,n,n,n,n]
    ]

    @directions = {
      '1' => [-1, -1],
      '2' => [-1,  0],
      '3' => [-1, +1],
      '4' => [ 0, -1],
      '5' => [ 0,  0],
      '6' => [ 0, +1],
      '7' => [+1, -1],
      '8' => [+1,  0],
      '9' => [+1, +1]
    }

    @turn = b
  end

  def move_black(x, y)
    reverse_candidates = check(x, y)
    reverse!(reverse_candidates)
    @board[x][y] = true
  end

  def move_white(x, y)
    reverse_candidates = check(x, y)
    reverse!(reverse_candidates)
    @board[x][y] = false
  end

  def check(x, y)
    @directions.each_with_object([]) do |(dir, (a, b)), candidate_pieces|
      check_direction(x + a, y + b, dir, candidate_pieces)
    end
  end

  private

  # 対戦相手のピースかどうか
  def opponent_piece?(piece)
    piece != @turn && !piece.nil?
  end

  def check_direction(x, y, dir, candidate_pieces)
    if opponent_piece?(@board[x][y])
      candidate_pieces << [x, y]

      a, b = @directions[dir]
      check_direction(x + a, y + b, dir, candidate_pieces)
    end
  end

  def reverse!(pieces)
    pieces.each {|x, y| @board[x][y] = @turn }
  end
end
