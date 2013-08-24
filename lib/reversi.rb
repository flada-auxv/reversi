require_relative 'reversi/piece'
require_relative 'reversi/board'

module Reversi
  class Game
    class IllegalMovementError < StandardError; end

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
      @board = Reversi::Board.new

      @turn = [:black, :white].cycle

      @reversible_pieces = []
    end

    def board(coordinates_str = nil)
      return @board unless coordinates_str

      @board[coordinates_str]
    end

    # TODO Boardへ？
    def pieces_coordinate_of(color = :black)
      @board.each_with_index.with_object([]) { |(x_line, x), res|
        if (y_idx = x_line.find_all_index(color))
          x_y_idx = [x].product(y_idx)
          res.push(*x_y_idx)
        end
      }
    end

    def current_turn_color
      @turn.peek
    end

    def turn_change
      @turn.next
    end

    def move(coordinates_str)
      @reversible_pieces = search_reversible(coordinates_str)

      raise IllegalMovementError unless valid_move?(coordinates_str)

      reverse!

      move_current_color_to(coordinates_str)
      turn_change
    end

    def search_reversible(coordinates_str)
      x, y = index_for(coordinates_str)
      DIRECTIONS.each_with_object([]) { |(dir, (a, b)), res|
        res << check_for_straight_line(x + a, y + b, dir)
      }.compact.flatten(1) # XXX ちょっとつらい？
    end

    private

    # どちらの石も置かれてない && ひっくり返せる石が一つでもある  => その座標に打てる
    def valid_move?(coordinates_str)
      @board[coordinates_str].none? && !@reversible_pieces.empty?
    end

    def move_current_color_to(coordinates_str)
      @board[coordinates_str].put(current_turn_color)
    end

    # 'f5' => [4,5], 'a2' => [1,0]
    def index_for(coordinate_str)
      return coordinate_str[1].to_i - 1, coordinate_str[0].ord - 'a'.ord
    end

    def check_for_straight_line(x, y, dir, candidates = [])
      return unless Reversi::Board.existing_coordinates?(x, y)

      case @board.board[x][y].color
      when :none then return
      when current_turn_color
        candidates.empty? ? nil : candidates
      else
        a, b = DIRECTIONS[dir]
        check_for_straight_line(x + a, y + b, dir, candidates << [x, y])
      end
    end

    def reverse!
      @reversible_pieces.each {|x, y| @board.board[x][y].reverse }
      @reversible_pieces.clear
    end
  end
end
