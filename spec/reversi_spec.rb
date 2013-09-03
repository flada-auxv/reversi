require 'spec_helper'

describe 'Reversi::Game' do
  let(:reversi) { Reversi::Game.new }

  describe '#initialize' do
    it { reversi.current_turn_color.should == :black }
  end

  describe '#move!' do
    context 'スタート -> 黒:"f5" の順に入力されたとき' do
      let(:e5_black) { Reversi::Piece.new(4, 4, :black) }

      #   a b c d e f g h
      # 1| | | | | | | | |
      # 2| | | | | | | | |
      # 3| | | | | | | | |
      # 4| | | |w|b| | | |
      # 5| | | |b|b|b| | |
      # 6| | | | | | | | |
      # 7| | | | | | | | |
      # 8| | | | | | | | |
      before do
        reversi.move!('f5')
      end

      specify '"e5"の石がひっくり返り、手番が白に移ること' do
        expect(reversi.board('e5')).to eq e5_black
        expect(reversi.current_turn_color).to eq :white
      end
    end

    context 'スタート -> 黒:"f5" -> 白:"f4" の順に入力されたとき' do
      let(:e4_white) { Reversi::Piece.new(3, 4, :white) }

      #   a b c d e f g h
      # 1| | | | | | | | |
      # 2| | | | | | | | |
      # 3| | | | | | | | |
      # 4| | | |w|b| | | |
      # 5| | | |b|b|b| | |
      # 6| | | | | | | | |
      # 7| | | | | | | | |
      # 8| | | | | | | | |
      before do
        reversi.move!('f5')
        reversi.move!('f4')
      end

      specify '"e4"の石がひっくり返り、手番が黒に移ること' do
        expect(reversi.board('e4')).to eq e4_white
        expect(reversi.current_turn_color).to eq :black
      end
    end

    context '短い手順で全滅するパターン' do
      let(:all_location) { ('a'..'h').to_a.product((1..8).to_a).map(&:join) }
      let(:black_location) { %w(e3 d4 e4 f4 c5 d5 e5 f5 g5 d6 e6 f6 e7) }

      before do
        %w(f5 d6 c5 f4 e7 f6 g5 e6 e3).each do |location|
          reversi.move!(location)
        end
      end

      specify 'すべての石が黒になっていること' do
        #   a b c d e f g h
        # 1| | | | | | | | |
        # 2| | | | | | | | |
        # 3| | | | |b| | | |
        # 4| | | |b|b|b| | |
        # 5| | |b|b|b|b|b| |
        # 6| | | |b|b|b| | |
        # 7| | | | |b| | | |
        # 8| | | | | | | | |
        black_location.each do |location|
          reversi.board[location].should be_black
        end

        (all_location - black_location).each do |location|
          reversi.board[location].should be_none
        end
      end
    end

    # @再現テスト
    context '隅まで一直線にひっくり返せるとき' do
      #   a b c d e f g h
      # 1| | | | | | | | |
      # 2| | | | | |w|w|w|
      # 3| | | | | | |w|w|
      # 4| | | |w|w|w|b|w|
      # 5| | | |b|b|b|b| |
      # 6| | | | | | | | |
      # 7| | | | | | | | |
      # 8| | | | | | | | |
      before do
        %w(f5 f4 g3 g4 g5 h4 h3 h2 g2 f2).each do |location|
          reversi.move!(location)
        end
      end

      specify '挟んでいない"g3"・"h3"の石がひっくり返らないこと' do
        reversi.move!('f3')

        reversi.board['g3'].should be_white
        reversi.board['h3'].should be_white
      end
    end
  end

  describe '#check_reversible' do
    context 'ゲームスタート直後のとき' do
      let(:e5_white) { Reversi::Piece.new(4, 4, :white) }

      specify '挟んだ石が取得されること' do
        expect(reversi.check_reversible(reversi.board['f5'])).to eq [e5_white]
      end
    end

    context 'スタート -> 黒:"f5" の順に入力されたとき' do
      let(:e4_black) { Reversi::Piece.new(3, 4, :black) }

      #   a b c d e f g h
      # 1| | | | | | | | |
      # 2| | | | | | | | |
      # 3| | | | | | | | |
      # 4| | | |w|b| | | |
      # 5| | | |b|b|b| | |
      # 6| | | | | | | | |
      # 7| | | | | | | | |
      # 8| | | | | | | | |
      before do
        reversi.move!('f5')
      end

      specify '挟んだ石が取得されること' do
        expect(reversi.check_reversible(reversi.board['f4'])).to eq [e4_black]
      end
    end

    context 'スタート -> 黒:"f5" -> 白:"f4" の順に入力されたとき' do
      let(:e4_white) { Reversi::Piece.new(3, 4, :white) }
      let(:f4_white) { Reversi::Piece.new(3, 5, :white) }

      #   a b c d e f g h
      # 1| | | | | | | | |
      # 2| | | | | | | | |
      # 3| | | | | | | | |
      # 4| | | |w|w|w| | |
      # 5| | | |b|b|b| | |
      # 6| | | | | | | | |
      # 7| | | | | | | | |
      # 8| | | | | | | | |
      before do
        reversi.move!('f5')
        reversi.move!('f4')
      end

      context '複数の相手の石を挟んだとき' do
        specify '挟んだ石がすべて取得されること' do
          expect(reversi.check_reversible(reversi.board['f3'])).to eq [e4_white, f4_white]
        end
      end
    end
  end

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

  describe '#dup' do
    subject { reversi.dup }

    its('board.serialize') { should == reversi.board.serialize }
    specify do
      subject.board.each do |piece|
        piece.should_not equal reversi.board[piece.location]
      end
    end

    its(:current_turn_color) { should == reversi.current_turn_color }
    it { subject.instance_variable_get(:@turn).should_not equal reversi.instance_variable_get(:@turn) }
  end
end
