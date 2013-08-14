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
      #0 1 2 3 4 5 6 7
      [n,n,n,n,n,n,n,n], #0
      [n,n,n,n,n,n,n,n], #1
      [n,n,n,n,n,n,n,n], #2
      [n,n,n,w,b,n,n,n], #3
      [n,n,n,b,w,n,n,n], #4
      [n,n,n,n,n,n,n,n], #5
      [n,n,n,n,n,n,n,n], #6
      [n,n,n,n,n,n,n,n]  #7
    ]
  }

  describe '.initialize' do
    specify '黒と白の石が交互に2枚ずつ置かれていること' do
      expect(reversi.board).to eq board
    end
  end

  describe '#move' do
    context 'ゲームスタート直後の黒番で、"f5"と入力されたとき' do
      before do
        reversi.stub(:move_black)
        reversi.move('f5')
      end

      it { reversi.should have_received(:move_black).with(4, 5) }
    end

    context '黒:"f5", 白:"f4" と続けて入力されたとき' do
      before do
        reversi.stub(:move_white)
        reversi.move('f5')
        reversi.move('f4')
      end

      it { reversi.should have_received(:move_white).with(3, 5) }
    end

  end

  describe '#move_black' do
    before do
      reversi.move_black(4, 5)
    end

    specify '引数の座標に黒石が置かれること' do
      expect(reversi.board[4][5]).to eq black
    end

    specify '白番に移ること' do
      expect(reversi.current_turn).to eq white
    end
  end

  describe '#move_white' do
    before do
      reversi.move_black(4, 5)
      reversi.move_white(3, 5)
    end

    specify '引数の座標に白石が置かれること' do
      expect(reversi.board[3][5]).to eq white
    end

    specify '黒番に移ること' do
      expect(reversi.current_turn).to eq black
    end
  end

  describe '#check' do
    context 'ゲームスタート直後の黒番の場合' do
      context '横方向に相手の石を挟んだとき' do
        before do
          reversi.move_black(4, 5)
        end

        specify '挟んだ石がひっくり返されること' do
          expect(reversi.board[4][4]).to eq black
        end
      end

      context '縦方向に相手の石を挟んだとき' do
        before do
          reversi.move_black(2, 3)
        end

        specify '挟んだ石がひっくり返されること' do
          expect(reversi.board[3][3]).to eq black
        end
      end
    end

    context 'ゲームスタート直後の白番の場合' do
      before do
        reversi.move_black(4, 5)

        # [
        #   #0 1 2 3 4 5 6 7
        #   [n,n,n,n,n,n,n,n], #0
        #   [n,n,n,n,n,n,n,n], #1
        #   [n,n,n,n,n,n,n,n], #2
        #   [n,n,n,w,b,n,n,n], #3
        #   [n,n,n,b,b,b,n,n], #4
        #   [n,n,n,n,n,n,n,n], #5
        #   [n,n,n,n,n,n,n,n], #6
        #   [n,n,n,n,n,n,n,n]  #7
        # ]

      end

      context '横方向に相手の石を挟んだとき' do
        before do
          reversi.move_white(3, 5)
        end

        specify '挟んだ石がひっくり返されること' do
          expect(reversi.board[3][4]).to eq white
        end

        specify '隣接するが挟めていない石はひっくり返らないこと' do
          expect(reversi.board[4][5]).to eq black
        end
      end

      context '縦方向に相手の石を挟んだとき' do
        before do
          reversi.move_white(5, 3)
        end

        specify '挟んだ石がひっくり返されること' do
          expect(reversi.board[4][3]).to eq white
        end

        specify '隣接するが挟めていない石はひっくり返らないこと' do
          expect(reversi.board[4][4]).to eq black
        end
      end

      context '斜め方向に相手の石を挟んだとき' do
        before do
          reversi.move_white(5, 5)
        end

        specify '挟んだ石がひっくり返されること' do
          expect(reversi.board[4][4]).to eq white
        end

        specify '隣接するが挟めていない石はひっくり返らないこと' do
          expect(reversi.board[4][5]).to eq black
        end
      end
    end

    context '2巡目の場合' do
      before do
        reversi.move_black(2, 3)
        reversi.move_white(2, 4)

        # [
        #   #0 1 2 3 4 5 6 7
        #   [n,n,n,n,n,n,n,n], #0
        #   [n,n,n,n,n,n,n,n], #1
        #   [n,n,n,b,w,n,n,n], #2
        #   [n,n,n,b,w,n,n,n], #3
        #   [n,n,n,b,w,n,n,n], #4
        #   [n,n,n,n,n,n,n,n], #5
        #   [n,n,n,n,n,n,n,n], #6
        #   [n,n,n,n,n,n,n,n]  #7
        # ]
      end

      context '斜め方向に相手の石を挟んだとき' do
        before do
          reversi.move_black(1, 5)
        end

        specify '挟んだ石がひっくり返されること' do
          expect(reversi.board[2][4]).to eq black
        end
      end

      context '複数の相手の石を挟んだとき' do
        before do
          reversi.move_black(2, 5)
        end

        specify 'すべての挟んだ石がひっくり返されること' do
          expect(reversi.board[2][4]).to eq black
          expect(reversi.board[3][4]).to eq black
        end
      end
    end
  end
end
