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

  describe '.coordinates_for' do
    it { Reversi::Board.coordinates_for('a1').should == [0, 0] }
    it { Reversi::Board.coordinates_for('f5').should == [4, 5] }
  end

  describe '.existing_location?' do
    it { Reversi::Board.existing_location?('a1').should be_true }
    it { Reversi::Board.existing_location?('a9').should be_false }
    it { Reversi::Board.existing_location?('i3').should be_false }
  end

  describe '.next_location_for' do
    it { Reversi::Board.next_location_for('d4', '1',).should == 'c3' }
    it { Reversi::Board.next_location_for('d4', '5',).should be_nil }
    it { Reversi::Board.next_location_for('d4', '10').should be_nil }
  end

  describe '#all_pieces_of' do
    subject { game.board.all_pieces_of(color) }

    context 'スタート直後のとき' do
      let(:color) { :black }
      let(:result) {
        %w(d4 e5).map {|loc|
          Reversi::Piece.new(*Reversi::Board.coordinates_for(loc), :black)
        }
      }

      it { should == result }
    end

    context '短い手順で全滅するパターン' do
      let(:color) { :black }
      let(:result) {
        %w(e3 d4 e4 f4 c5 d5 e5 f5 g5 d6 e6 f6 e7).map {|loc|
          Reversi::Piece.new(*Reversi::Board.coordinates_for(loc), :black)
        }
      }

      before do
        %w(f5 d6 c5 f4 e7 f6 g5 e6 e3).each do |location|
          game.move!(location)
        end
      end

      it { should == result }
    end
  end

  describe '#next_piece_for' do
    # NOTE Piece#== が @color しか見ていないので #location の結果を比較している
    it { board.next_piece_for(ul, '6').location.should == ur.location }
    it { board.next_piece_for(ll, '3').location.should == ur.location }

    it { board.next_piece_for(board['a1'], '1').should be_nil }
    it { board.next_piece_for(board['h8'], '9').should be_nil }
  end

  describe '#search_movable_pieces_for' do
    # NOTE Piece#== が @color しか見ていないので #location の結果を比較している

    context 'スタート直後のとき' do
      #   a b c d e f g h
      # 1| | | | | | | | |
      # 2| | | | | | | | |
      # 3| | | |○| | | | |
      # 4| | |○|w|b| | | |
      # 5| | | |b|w|○| | |
      # 6| | | | |○| | | |
      # 7| | | | | | | | |
      # 8| | | | | | | | |
      let(:result) {
        %w(d3 c4 f5 e6).map {|loc|
          Reversi::Piece.new(*Reversi::Board.coordinates_for(loc), :non).location
        }
      }

      it { game.board.search_movable_pieces_for(:black).map(&:location).should =~ result }
    end

    context 'スタート -> 黒:"f5" の順に入力されたとき' do
      #   a b c d e f g h
      # 1| | | | | | | | |
      # 2| | | | | | | | |
      # 3| | | | | | | | |
      # 4| | | |w|b|○| | |
      # 5| | | |b|b|b| | |
      # 6| | | |○| |○| | |
      # 7| | | | | | | | |
      # 8| | | | | | | | |
      before do
        game.move!('f5')
      end

      let(:result) {
        %w(f4 d6 f6).map {|loc|
          Reversi::Piece.new(*Reversi::Board.coordinates_for(loc), :non).location
        }
      }

      it { game.board.search_movable_pieces_for(:white).map(&:location).should =~ result }
    end

    context 'スタート -> 黒:"f5" -> 白:"f4" -> 黒:"e3" の順に入力されたとき' do
      # NOTE 内部実装的に同じピースが複数回入力できるとして選択されるとき

      let(:result) { %w(d2 f2 d6 f6) }

      #   a b c d e f g h
      # 1| | | | | | | | |
      # 2| | | |○| |○| | |
      # 3| | | | |b| | | |
      # 4| | | |w|b|w| | |
      # 5| | | |b|b|b| | |
      # 6| | | |○| |○| | |
      # 7| | | | | | | | |
      # 8| | | | | | | | |
      before do
        %w(f5 f4 e3).each do |loc|
          game.move!(loc)
        end
      end

      it { game.board.search_movable_pieces_for(:white).map(&:location).should =~ result }
    end

    context 'スタート -> 黒:"f5" -> 白:"f4" -> 黒:"e3" の順に入力されたとき' do
      # NOTE 内部実装的に同じピースが複数回入力できるとして選択されるとき

      let(:result) { %w(d2 f2 d6 f6) }

      #   a b c d e f g h
      # 1| | | | | | | | |
      # 2| | | |○| |○| | |
      # 3| | | | |b| | | |
      # 4| | | |w|b|w| | |
      # 5| | | |b|b|b| | |
      # 6| | | |○| |○| | |
      # 7| | | | | | | | |
      # 8| | | | | | | | |
      before do
        %w(f5 f4 e3).each do |loc|
          game.move!(loc)
        end
      end

      it { game.board.search_movable_pieces_for(:white).map(&:location).should =~ result }
    end

    # @再現テスト
    context 'スタート -> 黒:"f5" -> 白:"f4" の順に入力されたとき' do
      # NOTE なんで??

      let(:result) { %w(c3 d3 e3 f3 g3) }

      #   a b c d e f g h
      # 1| | | | | | | | |
      # 2| | | | | | | | |
      # 3| | |○|○|○|○|○| |
      # 4| | | |w|w|w| | |
      # 5| | | |b|b|b| | |
      # 6| | | | | | | | |
      # 7| | | | | | | | |
      # 8| | | | | | | | |
      before do
        %w(f5 f4).each do |loc|
          game.move!(loc)
        end
      end

      it { game.board.search_movable_pieces_for(:black).map(&:location).should =~ result }
    end
  end

  describe '#serialize' do
    let(:piece_num) { Reversi::Board::BOARD_SIZE * Reversi::Board::BOARD_SIZE }
    let(:black_piece_idx) { [28, 35] }
    let(:white_piece_idex) { [27, 36] }
    let(:none_piece_idex) { (0...piece_num).to_a - black_piece_idx - white_piece_idex }

    subject { board.serialize }

    its(:size) { should == 64 }

    specify do
      black_piece_idx.each do |idx|
        subject[idx].should == :black
      end
    end

    specify do
      white_piece_idex.each do |idx|
        subject[idx].should == :white
      end
    end

    specify do
      none_piece_idex.each do |idx|
        subject[idx].should == :none
      end
    end
  end

  describe '#deep_copy' do
    subject { board.deep_copy }

    %w(a1 d4 e4 g5).each do |loc|
      specify do
        subject[loc].color.should == board[loc].color
        subject[loc].x.should == board[loc].x
        subject[loc].y.should == board[loc].y
        subject[loc].object_id.should_not == board[loc].object_id
      end
    end
  end
end
