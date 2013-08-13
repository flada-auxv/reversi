require 'spec_helper'

describe 'Reversi' do
  describe '#initialize' do
    let(:reversi) { Reversi.new }
    let(:board) {
      [
        [nil,nil,nil,nil,nil,nil,nil,nil],
        [nil,nil,nil,nil,nil,nil,nil,nil],
        [nil,nil,nil,nil,nil,nil,nil,nil],
        [nil,nil,nil,true,false,nil,nil,nil],
        [nil,nil,nil,false,true,nil,nil,nil],
        [nil,nil,nil,nil,nil,nil,nil,nil],
        [nil,nil,nil,nil,nil,nil,nil,nil],
        [nil,nil,nil,nil,nil,nil,nil,nil]
      ]
    }

    specify '黒と白のコマが交互に2枚ずつ置かれていること' do
      expect(reversi.board).to eq board
    end
  end
end
