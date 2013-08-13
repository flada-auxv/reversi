require 'spec_helper'

describe 'Reversi' do
  describe '.initialize' do
    let(:reversi) { Reversi.new }
    let(:b) { true }
    let(:w) { false }
    let(:n) { nil }
    let(:board) {
      [
        [n,n,n,n,n,n,n,n],
        [n,n,n,n,n,n,n,n],
        [n,n,n,n,n,n,n,n],
        [n,n,n,w,b,n,n,n],
        [n,n,n,b,w,n,n,n],
        [n,n,n,n,n,n,n,n],
        [n,n,n,n,n,n,n,n],
        [n,n,n,n,n,n,n,n]
      ]
    }

    specify '黒と白のコマが交互に2枚ずつ置かれていること' do
      expect(reversi.board).to eq board
    end
  end
end
