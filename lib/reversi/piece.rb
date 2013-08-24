# TODO Piece.new('e4') / Piece.new(:black) に対応する
# XXX color は :black or :white 以外は例外にするくらいはしてもよさそう
# XXX inspect ○ / × は辛いかも・・・ to_s が適当なのかなぁ

module Reversi
  class IllegalCoordinatesError < StandardError; end
  class Piece
    Y_LINE_CHAR_BASE = 'a'.ord

    attr_accessor :x, :y, :color

    def initialize(x, y, color = :none)
      @x = x
      @y = y
      @color = color

      check_coordinates!
    end

    def location
      sprintf('%s%s', (Y_LINE_CHAR_BASE + y).chr, x + 1)
    end

    def coordinates
      [x, y]
    end

    def reverse
      @color = case @color
      when :black
        :white
      when :white
        :black
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

    private

    def check_coordinates!
      unless Reversi::Game::BOARD_INDEX_RANGE === x && Reversi::Game::BOARD_INDEX_RANGE === y
        raise IllegalCoordinatesError
      end
    end
  end
end
