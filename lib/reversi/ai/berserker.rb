module Reversi
  module AI
    class Berserker
      def initialize
      end

      def analyze(game)
        game.board.search_movable_pieces_for(game.current_turn_color).sample.location
      end
    end
  end
end
