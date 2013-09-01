require 'yaml'
require_relative 'reversi/piece'
require_relative 'reversi/board'
require_relative 'reversi/io_supporter'
require_relative 'reversi/ai/berserker'

module Reversi
  class Game
    include IOSupporter

    COLORS = [:black, :white]

    class SkipException < StandardError; end
    class ExitException < StandardError; end

    class << self
      def skip
        raise SkipException
      end

      def exit
        raise ExitException
      end
    end

    def initialize(players_file_path = nil)
      @board = Reversi::Board.new

      @turn = COLORS.cycle

      @players = load_players(players_file_path)

      @reversible_pieces = []
    end

    def game_loop
      loop do
        print_board(board.search_movable_pieces_for(current_turn_color))

        begin
          if @players[current_turn_color] == :user
            redo unless (input = read_user_input)
          else
            input = @players[current_turn_color].analyze(self)
          end

          redo unless move!(input)

          exit if game_over?

        rescue SkipException
          turn_change
          redo
        rescue ExitException
          break
        end
      end
    end

    # 石が盤面の64の升目を全て埋め尽くした or 打つ場所が両者ともなくなった時点でゲーム終了
    def game_over?
      return true unless @board.any?(&:none?)

      both_sides_movable_pieces = COLORS.map {|color|
        @board.search_movable_pieces_for(color)
      }.flatten

      return true if both_sides_movable_pieces.empty?

      false
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

    def move!(location)
      piece = @board[location]
      @reversible_pieces = check_reversible(piece)

      unless valid_move?(piece)
        help
        return nil
      end

      reverse!
      piece.put(current_turn_color)

      turn_change

      true
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

    def load_players(players_file_path)
      return {black: :user, white: :user} unless players_file_path

      Psych.load_file(players_file_path).each_with_object({}) {|(k, v), res|
        res[k.to_sym] = if v == 'User'
          v.downcase.to_sym
        else
          Reversi::AI.const_get(v).new
        end
      }
    end
  end
end
