require_relative 'reversi/piece'
require_relative 'reversi/board'
require_relative 'reversi/io_supporter'
require_relative 'reversi/ai/berserker'

module Reversi
  class Game
    include IOSupporter

    class IllegalMovementError < StandardError; end
    class SkipException < StandardError; end
    class ExitException < StandardError; end

    def initialize
      @board = Reversi::Board.new

      @turn = [:black, :white].cycle

      @players = {black: :user, white: :ai}

      @ai = Reversi::AI::Berserker.new

      @reversible_pieces = []
    end

    def game_loop
      loop do
        print_board(board.search_movable_pieces_for(current_turn_color))

        if @players[current_turn_color] == :user
          begin
            input = read_user_input

          # FIXME 例外で遷移するのではなく、内部の振る舞いとしてもてるはず!!
          rescue SkipException
            turn_change
            redo
          rescue ExitException
            break
          end
        elsif @players[current_turn_color] == :ai
          input = @ai.analyze(self)
        end

        redo if input.nil?

        begin
          move(input)
        rescue IllegalMovementError
          help
          redo
        end
        # check_game_end
      end
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
