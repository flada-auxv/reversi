# TODO @board.board を何とかしたい 'a1' と 0, 0 のアクセスを統一する必要がある

require_relative 'reversi/piece'
require_relative 'reversi/board'

module Reversi
  class Game
    class IllegalMovementError < StandardError; end

    def initialize
      @board = Reversi::Board.new

      @turn = [:black, :white].cycle

      @reversible_pieces = []
    end

    def board(location = nil)
      return @board unless location

      @board[location]
    end

    def board_to_s
      @board.to_s
    end

    def score_of(color)
      @board.score[color]
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

    def move(location)
      @reversible_pieces = search_reversible(location)

      raise IllegalMovementError unless valid_move?(location)

      reverse!
      @board[location].put(current_turn_color)

      turn_change
    end

    def search_reversible(location)
      x, y = Reversi::Board.coordinates_for(location)

      Reversi::Board::DIRECTIONS.each_with_object([]) { |(dir, (a, b)), res|
        res << check_for_straight_line(Reversi::Board.next_location_for(location, dir), dir)
      }.compact.flatten(1) # XXX ちょっとつらい？
    end

    private

    # どちらの石も置かれてない && ひっくり返せる石が一つでもある  => その座標に打てる
    def valid_move?(location)
      @board[location].none? && !@reversible_pieces.empty?
    end

    def check_for_straight_line(location, dir, candidates = [])
      return unless Reversi::Board.existing_location?(location)

      case @board[location].color
      when :none then return
      when current_turn_color
        candidates.empty? ? nil : candidates
      else
        check_for_straight_line(Reversi::Board.next_location_for(location, dir), dir, candidates << @board[location])
      end
    end

    def reverse!
      @reversible_pieces.map(&:reverse)
      @reversible_pieces.clear
    end
  end
end
