require 'yaml'
require_relative 'reversi/piece'
require_relative 'reversi/board'
require_relative 'reversi/turn_table'
require_relative 'reversi/io_supporter'
require_relative 'reversi/ai/berserker'

module Reversi
  class Game
    prepend TurnTable
    include IOSupporter

    class IllegalMovementError < StandardError; end
    class SkipException < StandardError; end
    class ExitException < StandardError; end

    def initialize(players_file_path = nil)
      @board = Reversi::Board.new

      @players = load_players(players_file_path)

      @move_history = []
    end

    def game_loop
      loop do
        print_current_turn(self)
        print_board(self)

        begin
          if @players[current_turn_color] == :user
            redo unless (input = read_user_input)
          else
            input = @players[current_turn_color].analyze(self)
          end

          move!(input)

          raise ExitException if game_over?
        rescue IllegalMovementError
          help
          redo
        rescue SkipException
          skip
          turn_over!
          redo
        rescue ExitException
          exit
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

    def move!(location)
      move_piece, reversible_pieces = obtain_pieces!(location)

      move_piece.put(current_turn_color)
      reversible_pieces.map(&:reverse)

      turn_over!
      @move_history << location

      self
    end

    def obtain_pieces!(location)
      move_piece = @board[location]
      reversible_pieces = check_reversible(move_piece)

      raise IllegalMovementError unless valid_move?(move_piece, reversible_pieces)

      return move_piece, reversible_pieces
    end

    def check_reversible(piece)
      Reversi::Board::DIRECTIONS.keys.each_with_object([]) {|dir, res|
        next unless (next_piece = @board.next_piece_for(piece, dir))

        res << check_for_straight_line(next_piece, dir)
      }.compact.flatten(1)
    end

    def movable_pieces_for_current_turn_color
      @board.search_movable_pieces_for(current_turn_color)
    end

    def current_move
      @move_history.last
    end

    def dup
      super.tap {|copied|
        copied.instance_eval {
          @board = copied.board.deep_copy
          @turn = @turn.dup
          @move_history = @move_history.dup
        }
      }
    end

    def ==(other)
      self.board == other.board
      self.current_turn_color == other.current_turn_color
    end

    private

    # どちらの石も置かれてない && ひっくり返せる石が一つでもある  => その座標に打てる
    def valid_move?(piece, reversible_pieces)
      piece.none? && !reversible_pieces.empty?
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
