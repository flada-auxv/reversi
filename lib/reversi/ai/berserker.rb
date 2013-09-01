require_relative 'base'

module Reversi
  module AI
    class Berserker < Base
      def initialize
      end

      def analyze(game)
        Reversi::Game.skip unless (move_piece = game.board.search_movable_pieces_for(game.current_turn_color).sample)

        move_piece.location
      end
    end
  end
end
