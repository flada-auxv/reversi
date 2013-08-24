require 'spec_helper'

describe Reversi::Board do
  let(:game) { Reversi::Game.new }
  let(:board) { Reversi::Board.new }
  let(:n) { Reversi::Piece.new } # none_piece
  let(:ul) { Reversi::Piece.new(3, 3, :white) } # upper_left_white_piece
  let(:ur) { Reversi::Piece.new(3, 4, :black) } # upper_right_black_piece
  let(:ll) { Reversi::Piece.new(4, 3, :black) } # lowwer_left_black_piece
  let(:lr) { Reversi::Piece.new(4, 4, :white) } # lowwer_right_white_piece

  describe '#initialize' do
    let(:initial_board) {
      [
        #a  b  c  d  e  f  g  h
        [n ,n ,n ,n ,n ,n ,n ,n],# 1
        [n ,n ,n ,n ,n ,n ,n ,n],# 2
        [n ,n ,n ,n ,n ,n ,n ,n],# 3
        [n ,n ,n ,ul,ur,n ,n ,n],# 4
        [n ,n ,n ,ll,lr,n ,n ,n],# 5
        [n ,n ,n ,n ,n ,n ,n ,n],# 6
        [n ,n ,n ,n ,n ,n ,n ,n],# 7
        [n ,n ,n ,n ,n ,n ,n ,n] # 8
      ]
    }

    it { board.should == initial_board }
  end

  describe '#[]' do
    it { board['e4'].should == ur }
  end

  describe '#score' do
    context 'スタート直後のとき' do
      it { board.score.should == {black: 2, white: 2} }
    end

    context 'スタート直後の4つの石とa・b・c列がすべて黒石であるとき' do
      before do
        ('a'..'c').to_a.product((1..8).to_a).map(&:join).each do |coordinates_str|
          board[coordinates_str].put(:black)
        end
      end

      it { board.score.should == {black:26, white:2} }
    end
  end

  describe '.existing_coordinates?' do
    let(:n) { Reversi::Board::BOARD_SIZE }

    it { Reversi::Board.existing_coordinates?(0, n - 1).should be_true }
    it { Reversi::Board.existing_coordinates?(0, n).should be_false }
  end
end
