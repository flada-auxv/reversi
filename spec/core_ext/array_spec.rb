require 'spec_helper'

describe 'Array' do
  describe '#find_all_index' do
    subject { array.find_all_index(argument) }

    context '要素が一つも見つからなかった場合' do
      let(:array) { %w(black white black black white) }
      let(:argument) { 'ブラック羽川' }

      it { should == nil }
    end

    context '要素が文字列の配列の場合' do
      let(:array) { %w(black white black black white) }

      context '"black" が引数として渡されたとき' do
        let(:argument) { 'black' }

        it { should == [0, 2, 3] }
      end

      context ':black が引数として渡されたとき' do
        let(:argument) { :black }

        it { should == [0, 2, 3] }
      end
    end

    context '要素がシンボルの配列の場合' do
      let(:array) { %i(black white black black white) }

      context '"black" が引数として渡されたとき' do
        let(:argument) { 'black' }

        it { should == [0, 2, 3] }
      end

      context ':black が引数として渡されたとき' do
        let(:argument) { :black }

        it { should == [0, 2, 3] }
      end
    end

    context '要素が数字の配列の場合' do
      let(:array) { [1, 9, 8, 8, 0, 9, 1, 2] }

      let(:argument) { 8 }
      it { should == [2, 3] }
    end

    context '要素にnilが含まれる場合' do
      let(:array) { ['black', 'white', nil, 'black', 'black', 'white'] }

      let(:argument) { 'black' }
      it { should == [0, 3, 4] }
    end

    context '要素がごちゃ混ぜの場合' do
      let(:array) { ['black', 9, 8, :black, 0, :black, 1, :black] }

      context '"black" が引数として渡されたとき' do
        let(:argument) { 'black' }

        it { should == [0, 3, 5, 7] }
      end

      context ':black が引数として渡されたとき' do
        let(:argument) { :black }

        it { should == [0, 3, 5, 7] }
      end
    end
  end
end
