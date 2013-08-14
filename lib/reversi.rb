class Reversi
  class IllegalMovementError < StandardError; end

  BOARD_INDEX_RANGE = (0..7)

  DIRECTIONS = {
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

  attr_accessor :reversible_pieces

  def initialize
    n = nil
    b = :black
    w = :white

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

    @turn = [b, w].cycle

    @reversible_pieces = []
  end

  def board(coordinate_str = nil)
    return @board unless coordinate_str

    x, y = index_for(coordinate_str)
    @board[x][y]
  end

  def current_turn
    @turn.peek
  end

  def turn_change
    @turn.next
  end

  def move(coordinate_str)
    x, y = index_for(coordinate_str)
    check(x, y)
    reverse!

    @board[x][y] = current_turn
    turn_change
  end

  def check(x, y)
    DIRECTIONS.each_with_object([]) do |(dir, (a, b)), candidates|
      check_direction(x + a, y + b, dir, candidates)
    end

    raise IllegalMovementError if @reversible_pieces.empty?
  end

  private

  # 'f5' => [4,5], 'a2' => [1,0]
  def index_for(coordinate_str)
    return coordinate_str[1].to_i - 1, coordinate_str[0].ord - 'a'.ord
  end

  # 対戦相手のピースかどうか
  def opponent_piece?(piece)
    piece != current_turn && !piece.nil?
  end

  def self_piece?(piece)
    piece == current_turn
  end

  def check_direction(x, y, dir, candidates)
    # p "check_direction x:#{x}, y:#{y}, dir:#{dir}, candidates:#{candidates}, reversible_pieces:#{@reversible_pieces}"
    # p "@turn:#{@turn}"

    return unless BOARD_INDEX_RANGE === x && BOARD_INDEX_RANGE === y

    piece = @board[x][y]

    if piece.nil?
      return if candidates.empty?

      candidates.clear

    elsif self_piece?(piece)
      return if candidates.empty?

      @reversible_pieces += candidates
      candidates.clear

    elsif opponent_piece?(piece)
      candidates << [x, y]

      a, b = DIRECTIONS[dir]
      check_direction(x + a, y + b, dir, candidates)
    end
  end

  def reverse!
    # pp @board
    # p "reverse! => #{@reversible_pieces}"

    @reversible_pieces.each {|x, y| @board[x][y] = current_turn }
    @reversible_pieces.clear

    # pp @board
  end
end
