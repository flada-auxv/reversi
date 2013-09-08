require 'spec_helper'

describe Reversi::Rule do
  let(:reversi) { Reversi::Game.new }

  describe '#game_over?' do
    subject { reversi.game_over? }

    context '互いに打つ事の出来るマスが存在するとき' do
      context 'ゲームスタート直後のとき' do
        it { should be_false }
      end
    end

    context '互いに打つ事の出来るマスが存在しないとき' do
      context '全てのマスにいずれかの石が打たれたとき' do
        before do
          reversi.board.each do |piece|
            piece.put(:black)
          end
        end

        it { should be_true }
      end

      context 'いずれかの石が一つも無くなってしまったとき' do
        before do
          %w(f5 d6 c5 f4 e7 f6 g5 e6 e3).each do |location|
            reversi.move!(location)
          end
        end

        it { should be_true }
      end
    end
  end
end
