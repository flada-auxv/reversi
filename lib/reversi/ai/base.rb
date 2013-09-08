require_relative 'game_tree'

module Reversi
  module AI
    class NotImplementedError < StandardError; end

    class Base
      def analyze(game)
        raise Reversi::AI::NotImplementedError.new('AI クラスに #analyze が実装されていません')
      end
    end
  end
end
