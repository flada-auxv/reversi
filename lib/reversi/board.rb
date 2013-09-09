require 'stringio'
require_relative 'piece'

module Reversi
  class Board
    include Enumerable

    BOARD_SIZE = 8
    BOARD_INDEX_RANGE = (0..7)

    Y_LINE_CHAR_BASE = 'a'.ord

    INITIAL_PIECES_COORDINATES = {
      white: [[3,3], [4,4]],
      black: [[3,4], [4,3]]
    }

    DIRECTIONS = {
      '1' => [-1, -1], '2' => [-1,  0], '3' => [-1, +1],
      '4' => [ 0, -1], '5' => [ 0,  0], '6' => [ 0, +1],
      '7' => [+1, -1], '8' => [+1,  0], '9' => [+1, +1]
    }.reject {|k, v| k == '5'}

    private_class_method :new

    class << self
      def create
        new.instance_eval {
          @board = Array.new(BOARD_SIZE, nil).map.with_index {|_, x|
            BOARD_SIZE.times.map.with_index {|_, y|
              Reversi::Piece.new(x, y, lookup_color_by_coordinates(x, y))
            }
          }
          self
        }
      end

      # Board#serialize によって直列化された Board インスタンスの複製を作ります
      # @param [Array] Board#serialize によって直列化された Board の石情報の配列
      def create_by_seriarized_board(serialized_board)
        new.instance_eval {
          @board = serialized_board.each_slice(BOARD_SIZE).map.with_index {|x_line, x|
            x_line.map.with_index {|color, y|
              Reversi::Piece.new(x, y, color)
            }
          }
          self
        }
      end

      def coordinates_for(location)
        return location[1].to_i - 1, location[0].ord - Y_LINE_CHAR_BASE
      end
    end

    def each(&block)
      base = @board.flatten.each

      if block_given?
        base.with_object([]) {|piece, res| res << block.call(piece) }
      else
        base
      end
    end

    def [](location)
      x, y = Board.coordinates_for(location)
      @board[x][y]
    end

    def score
      {black: self.count(&:black?), white: self.count(&:white?)}
    end

    def ==(other)
      return nil unless other.respond_to?(:serialize)

      self.serialize == other.serialize
    end

    def all_pieces_of(color = :black)
      self.find_all(&"#{color}?".to_sym)
    end

    def next_piece_for(piece, dir)
      x, y = Board.coordinates_for(piece.location)
      _x , _y = DIRECTIONS[dir]

      return nil unless BOARD_INDEX_RANGE === (x += _x) && BOARD_INDEX_RANGE === (y += _y)

      @board[x][y]
    end

    def serialize
      @board.flatten.map(&:color)
    end

    def deep_copy
      Board.create_by_seriarized_board(self.serialize)
    end

    def search_movable_pieces_for(color)
      all_pieces_of(color).map.with_object([]) {|piece, res|
        DIRECTIONS.keys.each do |dir|
          next unless (next_piece = next_piece_for(piece, dir))

          res << search_for_straight_line(next_piece, color, dir)
        end
      }.compact.uniq
    end

    def inspect
      sio = StringIO.new("\n  a b c d e f g h\n")

      self.each_with_index do |piece, i|
        x_idx = i % Reversi::Board::BOARD_SIZE
        lineno = (i / Reversi::Board::BOARD_SIZE) + 1

        sio << lineno if x_idx == 0

        sio << '|'
        case piece.color
        when :none; sio << ' '
        when :black; sio << "\e[32mb\e[m"
        when :white; sio << "\e[33mw\e[m"
        end

        sio << "|\n" if x_idx == 7
      end

      sio.string
    end

    private

    def search_for_straight_line(piece, current_color, dir, candidates = [])
      case piece.color
      when :none
        candidates.empty? ? nil : piece
      when current_color
        nil
      else
        return nil unless (next_piece = next_piece_for(piece, dir))

        search_for_straight_line(next_piece, current_color, dir, candidates << piece)
      end
    end

    def lookup_color_by_coordinates(x, y)
      case [x, y]
        when *INITIAL_PIECES_COORDINATES[:white]; :white
        when *INITIAL_PIECES_COORDINATES[:black]; :black
        else :none
      end
    end
  end
end
