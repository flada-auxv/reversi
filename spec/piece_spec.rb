require 'spec_helper'

describe Reversi::Piece do
  let(:reversi) { Reversi::Game.new }
  let(:black_piece) { Reversi::Piece.new(3, 4, :black) }
  let(:white_piece) { Reversi::Piece.new(4, 4, :white) }
  let(:none_piece) { Reversi::Piece.new(3, 5) }

  describe '.initialize' do
    context 'ボードに存在しない座標で作成されたとき' do
      it do
        expect {
          Reversi::Piece.new(0, 9)
        }.to raise_error
      end
    end
  end

  describe '#location' do
    subject { black_piece.location }

    it { should == 'e4' }
  end

  describe '#coordinates' do
    subject { black_piece.coordinates }

    it { should == [3, 4] }
  end

  describe '#x' do
    subject { black_piece.x }

    it { should == 3 }
  end

  describe '#y' do
    subject { black_piece.y }

    it { should == 4 }
  end

  describe '#==' do
    let(:other_black_piece) { Reversi::Piece.new(4, 3, :black) }

    context '比較対象がReversi::Pieceだったとき' do
      subject { black_piece == other_black_piece }

      it { should be_true }
    end

    context '比較対象がReversi::Pieceではないとき' do
      subject { black_piece == :black }

      it { should be_false }
    end
  end

  describe '#reverse' do
    before { black_piece.reverse }

    it { black_piece.color == :white }
  end

  describe '#black?' do
    it { black_piece.black?.should be_true }
    it { white_piece.black?.should be_false }
  end

  describe '#white?' do
    it { white_piece.white?.should be_true }
    it { black_piece.white?.should be_false }
  end

  describe '#none?' do
    it { none_piece.none?.should be_true }
    it { black_piece.none?.should be_false }
  end
end
