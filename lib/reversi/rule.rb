module Reversi
  module Rule

    COLORS = [:black, :white]

    # ゲーム終了を判定する
    # 石が盤面の升目を全て埋め尽くした場合 or 打つ場所が両者とも無くなった場合、ゲーム終了としてtrueを返す
    # @return [Boolean] ゲーム続行不可能な状態かどうかの真偽値
    def game_over?
      return true unless @board.any?(&:none?)

      both_sides_movable_pieces = COLORS.map {|color|
        @board.search_movable_pieces_for(color)
      }.flatten

      return true if both_sides_movable_pieces.empty?

      false
    end

    # どちらの石も置かれてない && ひっくり返せる石が一つでもある  => その座標に打てる
    # @return [Boolean]
    def valid_move?(piece, reversible_pieces)
      piece.none? && !reversible_pieces.empty?
    end
  end
end
