module Reversi

  # @note Module#prepend で mixin して下さい
  module TurnTable
    class Turn
      attr_reader :color

      def initialize(color = :black)
        @color = color
      end

      # 自身の color を黒から白へ、白から黒へと遷移させる
      def next
        @color = ((@color == :black) ? :white : :black)
      end
    end

    def initialize
      @turn = Turn.new

      super
    end

    # 現在の手番を返す
    # @return [Symbol] :black or :white
    def current_turn_color
      @turn.color
    end

    # 手番を交代する
    # @return [Symbol] :black or :white
    def turn_over!
      @turn.next
    end
  end
end
