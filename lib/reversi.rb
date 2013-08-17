require_relative 'reversi/piece'

module Reversi
  class Game
    class IllegalMovementError < StandardError; end

    BOARD_SIZE = 8
    BOARD_INDEX_RANGE = (0..7)

    PIECES_COORDINATES_OF_START = {white: [[3,3], [4,4]], black: [[3,4], [4,3]]}

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
      @board = board_initialize

      @turn = [:black, :white].cycle

      @reversible_pieces = []
    end

    # XXX board もクラスにまとめても良いかも
    def board_initialize
      non_piece_board = Array.new(BOARD_SIZE, []).map { Array.new(BOARD_SIZE) }
      non_piece_board.map.with_index { |x_line, x|
        x_line.map.with_index { |_, y|
          color = case [x, y]
          when *PIECES_COORDINATES_OF_START[:white]
            :white
          when *PIECES_COORDINATES_OF_START[:black]
            :black
          else
            :none
          end

          Reversi::Piece.new(x, y, color)
        }
      }
    end

    def board(coordinate_str = nil)
      return @board unless coordinate_str

      x, y = index_for(coordinate_str)
      @board[x][y]
    end

    def pieces_coordinate_of(color = :black)
      @board.each_with_index.with_object([]) { |(x_line, x), res|
        if (y_idx = x_line.find_all_index(color))
          x_y_idx = [x].product(y_idx)
          res.push(*x_y_idx)
        end
      }
    end

    def current_turn
      @turn.peek
    end

    def turn_change
      @turn.next
    end

    def move(coordinate_str)
      x, y = index_for(coordinate_str)
      @reversible_pieces = search_reversible(x, y)

      raise IllegalMovementError unless valid_move?(x, y)

      reverse!

      move_current_color_to(x, y)
      turn_change
    end

    def search_reversible(x, y)
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
      @board[x][y].none? && !@reversible_pieces.empty?
    end

    def move_current_color_to(x, y)
      @board[x][y] = Reversi::Piece.new(x, y, current_turn)
    end

    # 'f5' => [4,5], 'a2' => [1,0]
    def index_for(coordinate_str)
      return coordinate_str[1].to_i - 1, coordinate_str[0].ord - 'a'.ord
    end

    def check_for_straight_line(x, y, dir, candidates = [])
      return unless existing_coordinates?(x, y)

      case @board[x][y].color
      when :none then return
      when current_turn
        candidates.empty? ? nil : candidates
      else
        a, b = DIRECTIONS[dir]
        check_for_straight_line(x + a, y + b, dir, candidates << [x, y])
      end
    end

    def existing_coordinates?(x, y)
      BOARD_INDEX_RANGE === x && BOARD_INDEX_RANGE === y
    end

    def reverse!
      @reversible_pieces.each {|x, y| @board[x][y].reverse }
      @reversible_pieces.clear
    end
  end
end
