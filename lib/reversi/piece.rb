module Reversi
  class Piece
    Y_LINE_CHAR_BASE = 'a'.ord

    attr_accessor :x, :y, :color

    def initialize(x, y, color)
      @x = x
      @y = y
      @color = color
    end

    def location
      sprintf('%s%s', (Y_LINE_CHAR_BASE + y).chr, x + 1)
    end

    def coordinates
      [x, y]
    end


    private

    def index_for(coordinate_str)
      return coordinate_str[1].to_i - 1, coordinate_str[0].ord - 'a'.ord
    end

  end
end
