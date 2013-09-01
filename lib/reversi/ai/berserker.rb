require_relative 'base'

module Reversi
  module AI
    class Berserker < Base
      def initialize
      end

      def analyze(game)
        game.board.search_movable_pieces_for(game.current_turn_color).sample.location
      end
    end
  end
end
