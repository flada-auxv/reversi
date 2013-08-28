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

    def score_of(color)
      @board.score[color]
    end

    def current_turn_color
      @turn.peek
    end

    def turn_change
      @turn.next
    end

    def move(location)
      piece = @board[location]
      @reversible_pieces = check_reversible(piece)

      raise IllegalMovementError unless valid_move?(piece)

      reverse!
      piece.put(current_turn_color)

      turn_change
    end

    def check_reversible(piece)
      Reversi::Board::DIRECTIONS.keys.each_with_object([]) { |dir, res|
        next unless (next_piece = @board.next_piece_for(piece, dir))
        res << check_for_straight_line(next_piece, dir)
      }.compact.flatten(1) # XXX ちょっとつらい？
    end

    private

    # どちらの石も置かれてない && ひっくり返せる石が一つでもある  => その座標に打てる
    def valid_move?(piece)
      piece.none? && !@reversible_pieces.empty?
    end

    def check_for_straight_line(piece, dir, candidates = [])
      case piece.color
      when :none then return
      when current_turn_color
        candidates.empty? ? nil : candidates
      else
        return nil unless (next_piece = @board.next_piece_for(piece, dir))
        check_for_straight_line(next_piece, dir, candidates << piece)
      end
    end

    def reverse!
      @reversible_pieces.map(&:reverse)
      @reversible_pieces.clear
    end
  end
end
