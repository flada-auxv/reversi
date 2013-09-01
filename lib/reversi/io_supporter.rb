module Reversi
  module IOSupporter
    INPUT_FORMAT = /[a-h][1-8]/

    def print_board(game)
      puts "turn -> #{game.current_turn_color}"
      puts "------------------"
      puts "  a b c d e f g h"

      sio = StringIO.new
      movable_pieces = game.board.search_movable_pieces_for(game.current_turn_color)

      game.board.each_with_index do |piece, i|
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

    def print_score
      puts "------------------"
      puts "black:#{score_of(:black)} -- white:#{score_of(:white)}"
      puts ''
    end

    def read_user_input
      print '>> '

      case input = STDIN.gets.chomp
      when 'skip' then skip
      when 'exit','end' then exit
      when 'score'
        print_score
        return nil
      when '' then return nil
      when INPUT_FORMAT then return input
      else
        help
        return nil
      end
    end

    def skip
      puts 'skipped!!'
      puts ''
      Reversi::Game.skip
    end

    def exit
      puts 'exit!!'
      print_board(self)
      print_score
      Reversi::Game.exit
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
  end
end
