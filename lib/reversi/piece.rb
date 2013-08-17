# TODO Piece.new('e4') / Piece.new(:black) に対応する
# XXX inspect ○ / × は辛いかも・・・ to_s が適当なのかなぁ

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
      return false unless other.respond_to?(:color)

      self.color == other.color
    end
  end
end
