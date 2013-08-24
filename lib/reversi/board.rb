require_relative 'piece'

module Reversi
  class Board
    attr_accessor :board

    BOARD_SIZE = 8
    BOARD_INDEX_RANGE = (0..7)

    Y_LINE_CHAR_BASE = 'a'.ord

    PIECE_COORDINATES_WHEN_STARTED = {
      white: [[3,3], [4,4]],
      black: [[3,4], [4,3]]
    }

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

    class << self
      def existing_coordinates?(x, y)
        BOARD_INDEX_RANGE === x && BOARD_INDEX_RANGE === y
      end
    end

    def initialize
      non_piece_board = Array.new(BOARD_SIZE, []).map { Array.new(BOARD_SIZE) }

      @board = non_piece_board.map.with_index { |x_line, x|
        x_line.map.with_index { |_, y|

          color = case [x, y]
          when *PIECE_COORDINATES_WHEN_STARTED[:white]; :white
          when *PIECE_COORDINATES_WHEN_STARTED[:black]; :black
          else :none
          end

          Reversi::Piece.new(x, y, color)
        }
      }
    end

    def [](coordinates_str)
      x, y = index_for(coordinates_str)

      @board[x][y]
    end

    def score
      all_pieces = @board.flatten

      {black: all_pieces.count(&:black?), white: all_pieces.count(&:white?)}
    end

    def to_s
      sio = StringIO.new

      @board.each_with_index do |x_line, i|
        sio << "#{i+1}"
        x_line.each do |y|
          sio << '|'
          if y.none?
            sio << ' '
          elsif y.black?
            sio << "\e[32mb\e[m"
          elsif y.white?
            sio << "\e[33mw\e[m"
          end
        end
        sio << "|\n"
      end

      sio.string
    end

    private

    def index_for(coordinates_str)
      return coordinates_str[1].to_i - 1, coordinates_str[0].ord - Y_LINE_CHAR_BASE
    end

    def ==(other)
      @board == other
    end
  end
end
