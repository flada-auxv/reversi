require 'spec_helper'

describe Piece do
  let(:reversi) { Reversi.new }
  let(:black_piece) { Piece.new(3, 4, :black) }

  describe '.initialize' do
    it { pending('とりあえずReversi本体へ取り込むのはあとで'); reversi.board['e4'].should == black_piece }
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
end
