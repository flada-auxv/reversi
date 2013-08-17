require 'spec_helper'

describe Reversi::Piece do
  let(:reversi) { Reversi::Game.new }
  let(:black_piece) { Reversi::Piece.new(3, 4, :black) }

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
end
