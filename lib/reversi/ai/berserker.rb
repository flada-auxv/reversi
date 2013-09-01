require_relative 'base'

module Reversi
  module AI
    class Berserker < Base
      def initialize
      end

      def analyze(game)
        unless (move_piece = game.board.search_movable_pieces_for(game.current_turn_color).sample)
          raise Reversi::Game::SkipException
        end

        move_piece.location
      end
    end
  end
end
