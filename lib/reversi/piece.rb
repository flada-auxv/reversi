module Reversi
  class Piece
    Y_LINE_CHAR_BASE = 'a'.ord

    attr_accessor :x, :y, :color

    def initialize(x = nil, y = nil, color = :none)
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

    def inspect
      case @color
      when :black then '○'
      when :white then '×'
      when :none then ' '
      end
    end

    def ==(other)
      self.color == other
    end
  end
end
