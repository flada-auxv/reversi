# TODO Piece.new('e4') / Piece.new(:black) に対応する
# XXX inspect ○ / × は辛いかも・・・ to_s が適当なのかなぁ

module Reversi
  class UnReversiblePieceError < StandardError; end

  class Piece
    attr_accessor :x, :y, :color

    def initialize(x = nil, y = nil, color = :none)
      @x = x
      @y = y
      @color = color
    end

    def location
      sprintf('%s%s', (Reversi::Board::Y_LINE_CHAR_BASE + y).chr, x + 1)
    end

    def coordinates
      [x, y]
    end

    def put(color)
      return nil unless none?

      @color = color
    end

    def reverse
      @color = case @color
      when :black; :white
      when :white; :black
      when :none; raise UnReversiblePieceError
      end
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

    [:black, :white, :none].each do |color|
      define_method("#{color}?") do
        @color == color
      end
    end
  end
end
