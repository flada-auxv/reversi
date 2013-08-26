require 'stringio'
require_relative 'piece'

module Reversi
  class Board
    include Enumerable

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
      def coordinates_for(location)
        return location[1].to_i - 1, location[0].ord - Y_LINE_CHAR_BASE
      end

      def existing_location?(location)
        x, y = coordinates_for(location)
        BOARD_INDEX_RANGE === x && BOARD_INDEX_RANGE === y
      end

      def next_location_for(location, dir)
        return nil unless DIRECTIONS.include?(dir)

        x, y = coordinates_for(location)
        _x, _y = DIRECTIONS[dir]

        sprintf('%s%s', ((y + _y) + Y_LINE_CHAR_BASE).chr, (x + _x) + 1)
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

    def each(&block)
      @board.flatten.each_with_object([]) do |piece, res|
        res << block.call(piece) if block_given?
      end
    end

    def [](location)
      x, y = Board.coordinates_for(location)
      @board[x][y]
    end

    def score
      all_pieces = @board.flatten

      {black: all_pieces.count(&:black?), white: all_pieces.count(&:white?)}
    end

    def ==(other)
      @board == other
    end

    def all_pieces_of(color = :black)
      @board.flatten.find_all(&"#{color}?".to_sym)
    end

    def next_piece_for(piece, dir)
      x, y = Board.coordinates_for(piece.location)
      _x , _y = DIRECTIONS[dir]

      return nil unless BOARD_INDEX_RANGE === (x += _x) && BOARD_INDEX_RANGE === (y += _y)

      @board[x][y]
    end

    def search_movable_pieces_for(color)
      all_pieces_of(color).map.with_object([]) {|piece, res|
        DIRECTIONS.keys.each do |dir|
          next unless (next_piece = next_piece_for(piece, dir))
          res << search_for_straight_line(next_piece, color, dir)
        end
      }.compact.uniq
    end

    private

    def search_for_straight_line(piece, current_color, dir, candidates = [])
      case piece.color
      when :none
        candidates.empty? ? nil : piece.movable!(current_color)
      when current_color
        nil
      else
        return nil unless (next_piece = next_piece_for(piece, dir))
        search_for_straight_line(next_piece, current_color, dir, candidates << piece)
      end
    end
  end
end
