require 'spec_helper'

describe Reversi::AI::GameTree do
  context '深さが1のツリーのとき' do
    let(:initial_game) { Reversi::Game.new }
    let(:game_tree) { Reversi::AI::GameTree.new(initial_game, 1) }
    let(:childrens) { %w(d3 c4 f5 e6).map {|loc| Reversi::Game.new.move!(loc) }}

    it { game_tree.root.children.count.should == 4 }
    it { game_tree.root.children.map(&:game_status).should =~ childrens }
    it { game_tree.root.children.map(&:depth).should == [1, 1, 1, 1] }
  end

  context '深さが2のツリーのとき' do
    let(:initial_game) { Reversi::Game.new }
    let(:game_tree) { Reversi::AI::GameTree.new(initial_game, 2) }
    let(:childrens) { %w(c3 e3 c5).map {|loc| Reversi::Game.new.move!('d3').move!(loc) }}

    it { game_tree.root.children[0].children.count.should == 3 }
    it { game_tree.root.children[0].game_status.should == initial_game.move!('d3') }
    it { game_tree.root.children[0].children.map(&:game_status).should =~ childrens }
  end

  describe '#all_leaves' do
    let(:initial_game) { Reversi::Game.new }

    context '深さが1のツリーのとき' do
      let(:game_tree) { Reversi::AI::GameTree.new(initial_game, 1) }
      let(:all_leaves) { game_tree.root.children }

      it { game_tree.all_leaves.should =~ all_leaves }
    end

    context '深さが2のツリーのとき' do
      let(:game_tree) { Reversi::AI::GameTree.new(initial_game, 2) }
      let(:all_leaves) {
        game_tree.root.each_children.with_object([]) do |child, res|
          child.each_children do |ch|
            res << ch
          end
        end
      }

      it { game_tree.all_leaves.should =~ all_leaves }
    end
  end
end

describe Reversi::AI::Node do
  let(:node) { Reversi::AI::Node.new(Reversi::Game.new) }

  describe '#add_child' do
    let(:child_node) { Reversi::AI::Node.new(Reversi::Game.new) }

    it { (node << child_node).should == [child_node] }
    it { node.add_child(child_node).should == [child_node] }
  end

  describe '#find_child_by_move' do
    let(:child_node_d3) { Reversi::AI::Node.new(Reversi::Game.new.move!('d3')) }
    let(:child_node_c4) { Reversi::AI::Node.new(Reversi::Game.new.move!('c4')) }

    before do
      node.add_child(child_node_d3)
      node.add_child(child_node_c4)
    end

    it { node.find_child_by_move('c4').should == child_node_c4 }
  end

  describe '#root?' do
    context '親のノードが存在しないとき' do
      it { node.root?.should be_true }
    end

    context '親のノードが存在するとき' do
      let(:child_node) { Reversi::AI::Node.new(Reversi::Game.new) }

      before do
        node.add_child(child_node)
      end

      it { child_node.root?.should be_false }
    end
  end

  describe '#leaf?' do
    context '子のノードが一つも存在しないとき' do
      context '根ではないとき' do
        before do
          node.stub(:root?).and_return(false)
        end

        it { node.leaf?.should be_true }
      end

      context '根であるとき' do
        before do
          node.stub(:root?).and_return(true)
        end

        it { node.leaf?.should be_false }
      end
    end

    context '子のノードが一つでも存在するとき' do
      let(:child_node) { Reversi::AI::Node.new(Reversi::Game.new) }

      before do
        node.add_child(child_node)
      end

      it { node.leaf?.should be_false }
    end
  end

  describe '#each_children' do
    let(:child_node_d3) { Reversi::AI::Node.new(Reversi::Game.new.move!('d3')) }
    let(:child_node_c4) { Reversi::AI::Node.new(Reversi::Game.new.move!('c4')) }
    let(:children) { [child_node_d3, child_node_c4] }

    before do
      node.add_child(child_node_d3)
      node.add_child(child_node_c4)
    end

    it {
      node.each_children.with_index do |child, i|
        child.should == children[i]
      end
    }

    it {
      node.each_children do |child|
        child.children == []
      end
    }
  end
end
