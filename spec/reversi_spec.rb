require 'spec_helper'

describe 'Reversi::Game' do
  let(:reversi) { Reversi::Game.new }

  describe '#initialize' do
    it { reversi.current_turn_color.should == :black }
  end

  describe '#pieces_coordinate_of' do

    subject { reversi.pieces_coordinate_of(color) }

    context 'スタート直後のとき' do
      let(:color) { :black }

      it { pending('これもBoardクラスに移す予定'); should == [[3, 4], [4, 3]] }
    end

    context '短い手順で全滅するパターン' do
      let(:color) { :black }

      # [
      #   #a b c d e f g h
      #   #0 1 2 3 4 5 6 7
      #   [n,n,n,n,n,n,n,n], #0 1
      #   [n,n,n,n,n,n,n,n], #1 2
      #   [n,n,n,n,b,n,n,n], #2 3
      #   [n,n,n,b,b,b,n,n], #3 4
      #   [n,n,b,b,b,b,b,n], #4 5
      #   [n,n,n,b,b,b,n,n], #5 6
      #   [n,n,n,n,b,n,n,n], #6 7
      #   [n,n,n,n,n,n,n,n]  #7 8
      # ]
      before do
        %w(f5 d6 c5 f4 e7 f6 g5 e6 e3).each do |coordinate_str|
          reversi.move(coordinate_str)
        end
      end

      it { pending('これもBoardクラスに移す予定'); should == [[2,4],[3,3],[3,4],[3,5],[4,2],[4,3],[4,4],[4,5],[4,6],[5,3],[5,4],[5,5],[6,4]] }
    end
  end

  describe '#move' do
    context 'スタート -> 黒:"f5" の順に入力されたとき' do
      let(:e5_black) { Reversi::Piece.new(4, 4, :black) }

      #    a b c d e f g h
      #   #0 1 2 3 4 5 6 7
      #   [n,n,n,n,n,n,n,n], #0 1
      #   [n,n,n,n,n,n,n,n], #1 2
      #   [n,n,n,n,n,n,n,n], #2 3
      #   [n,n,n,w,b,n,n,n], #3 4
      #   [n,n,n,b,b,b,n,n], #4 5
      #   [n,n,n,n,n,n,n,n], #5 6
      #   [n,n,n,n,n,n,n,n], #6 7
      #   [n,n,n,n,n,n,n,n]  #7 8
      before do
        reversi.move('f5')
      end

      specify '"e5"の石がひっくり返り、手番が白に移ること' do
        expect(reversi.board('e5')).to eq e5_black
        expect(reversi.current_turn_color).to eq :white
      end
    end

    context 'スタート -> 黒:"f5" -> 白:"f4" の順に入力されたとき' do
      let(:e4_white) { Reversi::Piece.new(3, 4, :white) }

      #    a b c d e f g h
      #   #0 1 2 3 4 5 6 7
      #   [n,n,n,n,n,n,n,n], #0 1
      #   [n,n,n,n,n,n,n,n], #1 2
      #   [n,n,n,n,n,n,n,n], #2 3
      #   [n,n,n,w,b,n,n,n], #3 4
      #   [n,n,n,b,b,b,n,n], #4 5
      #   [n,n,n,n,n,n,n,n], #5 6
      #   [n,n,n,n,n,n,n,n], #6 7
      #   [n,n,n,n,n,n,n,n]  #7 8
      before do
        reversi.move('f5')
        reversi.move('f4')
      end

      specify '"e4"の石がひっくり返り、手番が黒に移ること' do
        expect(reversi.board('e4')).to eq e4_white
        expect(reversi.current_turn_color).to eq :black
      end
    end

    context '短い手順で全滅するパターン' do
      let(:completely_black_board) {
        [
          #a b c d e f g h
          #0 1 2 3 4 5 6 7
          [n,n,n,n,n,n,n,n], #0 1
          [n,n,n,n,n,n,n,n], #1 2
          [n,n,n,n,b,n,n,n], #2 3
          [n,n,n,b,b,b,n,n], #3 4
          [n,n,b,b,b,b,b,n], #4 5
          [n,n,n,b,b,b,n,n], #5 6
          [n,n,n,n,b,n,n,n], #6 7
          [n,n,n,n,n,n,n,n]  #7 8
        ]
      }

      before do
        %w(f5 d6 c5 f4 e7 f6 g5 e6 e3).each do |coordinate_str|
          reversi.move(coordinate_str)
        end
      end

      specify 'すべての石が黒になっていること' do
        pending('ちょっと疲れた・・・')
        expect(reversi.board).to eq completely_black_board
      end
    end

    # @再現テスト
    context '隅まで一直線にひっくり返せるとき' do
      #   a b c d e f g h
      # 1| | | | | | | | |
      # 2| | | | | |w|w|w|
      # 3| | | | | | |w|w|
      # 4| | | |w|w|w|b|w|
      # 5| | | |b|b|b|b| |
      # 6| | | | | | | | |
      # 7| | | | | | | | |
      # 8| | | | | | | | |
      before do
        %w(f5 f4 g3 g4 g5 h4 h3 h2 g2 f2).each do |coordinate_str|
          reversi.move(coordinate_str)
        end
      end

      specify '挟んでいない"g3"・"h3"の石がひっくり返らないこと' do
        reversi.move('f3')

        reversi.board['g3'].should be_white
        reversi.board['h3'].should be_white
      end
    end

    # @再現テスト
    context '既に相手の石がある かつ そこにもし打てた場合ら挟める石が一つでもある ような箇所に入力されたとき' do
      specify '例外が発生すること' do
        pending('moveを使ってテストの準備を書きなおさないと')

        expect {
          reversi.move('d6')
        }.to raise_error
      end
    end
  end

  describe '#search_reversible' do
    context 'ゲームスタート直後のとき' do
      specify '挟んだ石の座標が取得されること' do
        expect(reversi.search_reversible('f5')).to eq [[4, 4]]
      end
    end

    context 'スタート -> 黒:"f5" の順に入力されたとき' do
      #    a b c d e f g h
      #   #0 1 2 3 4 5 6 7
      #   [n,n,n,n,n,n,n,n], #0 1
      #   [n,n,n,n,n,n,n,n], #1 2
      #   [n,n,n,n,n,n,n,n], #2 3
      #   [n,n,n,w,b,n,n,n], #3 4
      #   [n,n,n,b,b,b,n,n], #4 5
      #   [n,n,n,n,n,n,n,n], #5 6
      #   [n,n,n,n,n,n,n,n], #6 7
      #   [n,n,n,n,n,n,n,n]  #7 8
      before do
        reversi.move('f5')
      end

      specify '挟んだ石の座標が取得されること' do
        expect(reversi.search_reversible('f4')).to eq [[3, 4]]
      end
    end

    context 'スタート -> 黒:"f5" -> 白:"f4" の順に入力されたとき' do
      #    a b c d e f g h
      #   #0 1 2 3 4 5 6 7
      #   [n,n,n,n,n,n,n,n], #0 1
      #   [n,n,n,n,n,n,n,n], #1 2
      #   [n,n,n,n,n,n,n,n], #2 3
      #   [n,n,n,w,w,w,n,n], #3 4
      #   [n,n,n,b,b,b,n,n], #4 5
      #   [n,n,n,n,n,n,n,n], #5 6
      #   [n,n,n,n,n,n,n,n], #6 7
      #   [n,n,n,n,n,n,n,n]  #7 8
      before do
        reversi.move('f5')
        reversi.move('f4')
      end

      context '複数の相手の石を挟んだとき' do
        specify '挟んだ石の座標がすべて取得されること' do
          expect(reversi.search_reversible('f3')).to eq [[3, 4], [3, 5]]
        end
      end
    end
  end
end
