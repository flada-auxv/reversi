require_relative 'reversi/piece'
require_relative 'reversi/board'

Player = Struct.new(:color, :type) {
  %w(ai user).each do |_type|
    define_method("#{_type}?") do
      type == _type.to_sym
    end
  end
}

module Reversi
  class Game
    class IllegalMovementError < StandardError; end
    class SkipException < StandardError; end
    class ExitException < StandardError; end

    def initialize
      @board = Reversi::Board.new

      @turn = [Player.new(:black, :user), Player.new(:white, :user)].cycle

      @reversible_pieces = []
    end

    def game_loop
      loop do
        if @turn.peek.user?
          print_board(board.search_movable_pieces_for(current_turn_color))

          begin
            input = read_user_input

          # FIXME 例外で遷移するのではなく、内部の振る舞いとしてもてるはず!!
          rescue SkipException
            turn_change
            redo
          rescue ExitException
            break
          end
        elsif @turn.peek.ai?
          input = ai(self)
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

    def print_board(movable_pieces)
      puts "turn -> #{current_turn_color}"
      puts "------------------"
      puts "  a b c d e f g h"

      sio = StringIO.new

      board.each_with_index do |piece, i|
        x_idx = i % Reversi::Board::BOARD_SIZE
        lineno = (i / Reversi::Board::BOARD_SIZE) + 1

        sio << lineno if x_idx == 0

        sio << '|'
        case piece.color
        when :none; movable_pieces.map(&:location).include?(piece.location) ? sio << '○' : sio << ' '
        when :black; sio << "\e[32mb\e[m"
        when :white; sio << "\e[33mw\e[m"
        end

        sio << "|\n" if x_idx == 7
      end

      puts sio.string
      puts ''
    end

    INPUT_FORMAT = /[a-h][1-8]/

    def board(location = nil)
      return @board unless location

      @board[location]
    end

    def score_of(color)
      @board.score[color]
    end

    def current_turn_color
      @turn.peek.color
    end

    def turn_change
      @turn.next.color
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

    def read_user_input
      print '>> '

      case input = readline.chomp
      when 'skip'
        puts 'skipped!!'
        raise SkipException
      when 'exit','end'
        puts 'exit!!'
        print_score
        raise ExitException
      when 'score'
        print_score
        return nil
      when ''
        return nil
      when INPUT_FORMAT
        return input
      else
        help
        return nil
      end
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

    def help
      puts <<-HELP

❨╯#°□°❩╯<(そこには石を置く事ができません!!)
❨╯°□°❩╯<(オセロは初めてかい？)

『石の置き方』
石を置く場所は、列・行の順に指定します 例）c3

『便利なコマンド』
skip:  石を置く場所が無い場合に、自分の手順を飛ばせます
score: 現在のスコアを表示させます
exit:  ゲームを終了させます ❨╯°□°❩╯︵┻━┻

❨╯°□°❩╯<(もう一度だけチャンスを与えてやる)

      HELP
    end

    def print_score
      puts "------------------"
      puts "black:#{score_of(:black)} -- white:#{score_of(:white)}"
      puts ''
    end
  end
end
