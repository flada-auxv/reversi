require 'spec_helper'

describe Reversi::Piece do
  let(:reversi) { Reversi::Game.new }
  let(:black_piece) { Reversi::Piece.new(3, 4, :black) }
  let(:white_piece) { Reversi::Piece.new(4, 4, :white) }
  let(:none_piece) { Reversi::Piece.new }

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
    context '黒石のマスだったとき' do
      subject { black_piece.color }

      before do
        black_piece.reverse
      end

      it { should == :white }
    end

    context 'どちらの石も置かれていないマスだったとき' do
      it do
        expect {
          none_piece.reverse
        }.to raise_error
      end
    end
  end

  describe '#put' do
    context '石の無いマスだったとき' do
      specify '引数の色の石が置かれ、返り値はその色であること' do
        none_piece.put(:black).should == :black
        none_piece.color.should == :black
      end
    end

    context '既に石が置いてあるマスだったとき' do
      specify '石の色は変わらず、nilを返すこと' do
        black_piece.put(:white).should == nil
        black_piece.color.should == :black
      end
    end
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
