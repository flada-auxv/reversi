class Reversi
  class IllegalMovementError < StandardError; end

  attr_accessor :board, :turn, :reversible_pieces

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
    # '5' => [ 0,  0],
      '6' => [ 0, +1],
      '7' => [+1, -1],
      '8' => [+1,  0],
      '9' => [+1, +1]
    }

    @turn = b

    @reversible_pieces = []
  end

  def move_black(x, y)
    check(x, y)
    reverse!

    @board[x][y] = @turn

    @turn = false
  end

  def move_white(x, y)
    check(x, y)
    reverse!

    @board[x][y] = @turn

    @turn = true
   end

  def check(x, y)
    @directions.each_with_object([]) do |(dir, (a, b)), candidate_pieces|
      check_direction(x + a, y + b, dir, candidate_pieces)
    end

    raise IllegalMovementError if @reversible_pieces.empty?
  end

  private

  # 対戦相手のピースかどうか
  def opponent_piece?(piece)
    piece != @turn && !piece.nil?
  end

  def self_piece?(piece)
    piece == @turn
  end

  def check_direction(x, y, dir, candidates)
    # p "check_direction x:#{x}, y:#{y}, dir:#{dir}, candidates:#{candidates}, reversible_pieces:#{@reversible_pieces}"
    # p "@turn:#{@turn}"

    if @board[x][y].nil?
      return if candidates.empty?

      candidates.clear

    elsif self_piece?(@board[x][y])
      return if candidates.empty?

      @reversible_pieces += candidates
      candidates.clear

    elsif opponent_piece?(@board[x][y])
      candidates << [x, y]

      a, b = @directions[dir]
      check_direction(x + a, y + b, dir, candidates)
    end
  end

  def reverse!
    # pp @board
    # p "reverse! => #{@reversible_pieces}"

    @reversible_pieces.each {|x, y| @board[x][y] = @turn }
    @reversible_pieces.clear

    # pp @board
  end
end
