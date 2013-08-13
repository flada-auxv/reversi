require 'spec_helper'

describe 'Reversi' do
  let(:reversi) { Reversi.new }

  describe '.initialize' do
    let(:b) { true }
    let(:w) { false }
    let(:n) { nil }
    let(:board) {
      [
        #a b c d e f g h
        #0 1 2 3 4 5 6 7
        [n,n,n,n,n,n,n,n], #1 0
        [n,n,n,n,n,n,n,n], #2 1
        [n,n,n,n,n,n,n,n], #3 2
        [n,n,n,w,b,n,n,n], #4 3
        [n,n,n,b,w,n,n,n], #5 4
        [n,n,n,n,n,n,n,n], #6 5
        [n,n,n,n,n,n,n,n], #7 6
        [n,n,n,n,n,n,n,n]  #8 7
      ]
    }

    specify '黒と白の石が交互に2枚ずつ置かれていること' do
      expect(reversi.board).to eq board
    end
  end

  describe '#move_black' do
    before do
      reversi.move_black(5, 5)
    end

    specify '引数の座標に黒石が置かれること' do
      expect(reversi.board[5][5]).to eq true
    end
  end

  describe '#move_white' do
    before do
      reversi.move_white(5, 5)
    end

    specify '引数の座標に白石が置かれること' do
      expect(reversi.board[5][5]).to eq false
    end
  end
end
