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
    @reversible_pieces = check_reversible(x, y)

    raise IllegalMovementError unless valid_move?(x, y)

    reverse!

    move_current_color_to(x, y)
    turn_change
  end

  def check_reversible(x, y)
    DIRECTIONS.each_with_object([]) { |(dir, (a, b)), res|
      res << check_for_straight_line(x + a, y + b, dir)
    }.compact.flatten(1) # XXX ちょっとつらい？
  end

  def score
    all_pieces = @board.flatten

    return all_pieces.count(:black), all_pieces.count(:white)
  end


  private

  # どちらの石も置かれてない && ひっくり返せる石が一つでもある  => その座標に打てる
  def valid_move?(x, y)
    @board[x][y].nil? && !@reversible_pieces.empty?
  end

  def move_current_color_to(x, y)
    @board[x][y] = current_turn
  end

  # 'f5' => [4,5], 'a2' => [1,0]
  def index_for(coordinate_str)
    return coordinate_str[1].to_i - 1, coordinate_str[0].ord - 'a'.ord
  end

  # 対戦相手のピースかどうか
  def opponent_piece?
    ->(piece) { piece != current_turn && !piece.nil? }
  end

  def self_piece?
    ->(piece) { piece == current_turn }
  end

  def check_for_straight_line(x, y, dir, candidates = [])
    return unless existing_coordinates?(x, y)

    case @board[x][y]
    when nil then return
    when self_piece?
      candidates.empty? ? nil : candidates
    when opponent_piece?
      a, b = DIRECTIONS[dir]
      check_for_straight_line(x + a, y + b, dir, candidates << [x, y])
    end
  end

  def existing_coordinates?(x, y)
    BOARD_INDEX_RANGE === x && BOARD_INDEX_RANGE === y
  end

  def reverse!
    @reversible_pieces.each {|x, y| @board[x][y] = current_turn }
    @reversible_pieces.clear
  end
end
