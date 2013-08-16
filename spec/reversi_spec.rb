require 'spec_helper'

describe 'Reversi' do
  let(:reversi) { Reversi.new }
  let(:b) { :black }
  let(:black) { :black }
  let(:w) { :white }
  let(:white) { :white }
  let(:n) { nil }
  let(:board) {
    [
      #a b c d e f g h
      #0 1 2 3 4 5 6 7
      [n,n,n,n,n,n,n,n], #0 1
      [n,n,n,n,n,n,n,n], #1 2
      [n,n,n,n,n,n,n,n], #2 3
      [n,n,n,w,b,n,n,n], #3 4
      [n,n,n,b,w,n,n,n], #4 5
      [n,n,n,n,n,n,n,n], #5 6
      [n,n,n,n,n,n,n,n], #6 7
      [n,n,n,n,n,n,n,n]  #7 8
    ]
  }

  describe '.initialize' do
    specify '黒と白の石が交互に2枚ずつ置かれていること' do
      expect(reversi.board).to eq board
    end
  end

  describe '#score' do
    subject { reversi.score }

    context 'スタート直後のとき' do
      it { should == [2, 2] }
    end

    context '短い手順で全滅するパターン' do
      before do
        %w(f5 d6 c5 f4 e7 f6 g5 e6 e3).each do |coordinate_str|
          reversi.move(coordinate_str)
        end
      end

      it { should == [13, 0] }
    end
  end

  describe '#board' do
    specify '引数を"e4"として受け取り、その座標の石の情報を返却すること' do
      expect(reversi.board('e4')).to eq black
    end
  end

  describe '#move' do
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

      specify '"e5"の石がひっくり返り、手番が白に移ること' do
        expect(reversi.board('e5')).to eq black
        expect(reversi.current_turn).to eq white
      end
    end

    context 'スタート -> 黒:"f5" -> 白:"f4" の順に入力されたとき' do
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
        expect(reversi.board('e4')).to eq white
        expect(reversi.current_turn).to eq black
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
        expect(reversi.board).to eq completely_black_board
      end
    end

    # リグレッションテスト
    context '隅まで一直線にひっくり返せるとき' do
      let(:before_board) {
        [
          #a b c d e f g h
          #0 1 2 3 4 5 6 7
          [n,n,n,n,n,n,n,n], #0 1
          [n,n,n,n,n,w,w,w], #1 2
          [n,n,n,n,n,n,w,w], #2 3
          [n,n,n,w,w,w,b,w], #3 4
          [n,n,n,b,b,b,b,n], #4 5
          [n,n,n,n,n,n,n,n], #5 6
          [n,n,n,n,n,n,n,n], #6 7
          [n,n,n,n,n,n,n,n]  #7 8
        ]
      }

      let(:result_board) {
        [
          #a b c d e f g h
          #0 1 2 3 4 5 6 7
          [n,n,n,n,n,n,n,n], #0 1
          [n,n,n,n,n,w,w,w], #1 2
          [n,n,n,n,n,b,w,w], #2 3
          [n,n,n,w,b,b,b,w], #3 4
          [n,n,n,b,b,b,b,n], #4 5
          [n,n,n,n,n,n,n,n], #5 6
          [n,n,n,n,n,n,n,n], #6 7
          [n,n,n,n,n,n,n,n]  #7 8
        ]
      }

      before do
        %w(f5 f4 g3 g4 g5 h4 h3 h2 g2 f2).each do |coordinate_str|
          reversi.move(coordinate_str)
        end
      end

      specify '挟んでいない石 "g3"・"h3" がひっくり返らないこと' do
        reversi.move('f3')
        expect(reversi.board).to eq result_board
      end
    end

    # リグレッションテスト
    context '既に相手の石がある かつ そこにもし打てた場合ら挟める石が一つでもある ような箇所に入力されたとき' do
      let(:halfway_board) {
        [
          #a b c d e f g h
          #0 1 2 3 4 5 6 7
          [n,n,n,n,n,n,n,n], #0 1
          [n,n,n,n,n,n,n,n], #1 2
          [n,n,n,w,n,n,n,n], #2 3
          [n,n,b,w,b,n,n,n], #3 4
          [n,n,n,b,b,n,n,n], #4 5
          [n,n,b,b,b,n,n,n], #5 6
          [n,n,n,n,n,n,n,n], #6 7
          [n,n,n,n,n,n,n,n]  #7 8
        ]
      }

      before do
        # FIXME Reversi#board をスタブすると上手くいかない
        reversi.instance_variable_set(:@board, halfway_board)
        reversi.turn_change

        reversi.stub(:move_current_color_to)
        reversi.stub(:reverse!)
      end

      specify '例外が発生すること' do
        expect {
          reversi.move('d6')
        }.to raise_error
      end
    end
  end

  describe '#check_reversible' do
    context 'ゲームスタート直後のとき' do
      specify '挟んだ石の座標が取得されること' do
        reversi.check_reversible(4, 5)
        expect(reversi.reversible_pieces).to eq [[4, 4]]
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
        reversi.check_reversible(3, 5)
        expect(reversi.reversible_pieces).to eq [[3, 4]]
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
          reversi.check_reversible(2, 5)
          expect(reversi.reversible_pieces).to eq [[3, 4], [3, 5]]
        end
      end
    end
  end
end
