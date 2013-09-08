module Reversi
  module IOSupporter
    INPUT_FORMAT = /[a-h][1-8]/

    def print_current_turn
      mark = {black: ' ', white: ' '}
      mark[self.current_turn_color] = '*'

      puts <<-EOS

turn:
[#{mark[:black]}] black
[#{mark[:white]}] white

      EOS
    end

    def print_board
      puts '  a b c d e f g h'

      sio = StringIO.new

      self.board.each_with_index do |piece, i|
        x_idx = i % Reversi::Board::BOARD_SIZE
        lineno = (i / Reversi::Board::BOARD_SIZE) + 1

        sio << lineno if x_idx == 0

        sio << '|'
        case piece.color
        when :none
          if self.movable_pieces_for_current_turn_color.map(&:location).include?(piece.location)
            sio << '○'
          else
            sio << ' '
          end
        when :black; sio << "\e[32mb\e[m"
        when :white; sio << "\e[33mw\e[m"
        end

        sio << "|\n" if x_idx == 7
      end

      puts sio.string
      puts ''
    end

    def print_score
      puts "black:#{score_of(:black)} -- white:#{score_of(:white)}"
      puts ''
    end

    def read_user_input
      print '>> '

      case input = STDIN.gets.chomp
      when 'skip' then raise Reversi::Game::SkipException
      when 'exit','end' then raise Reversi::Game::ExitException
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
    end

    def exit
      puts 'exit!!'
      puts ''
      print_board(self)
      print_score
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
