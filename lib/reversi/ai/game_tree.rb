module Reversi
  module AI
    class GameTree
      attr_accessor :root
      def initialize(game, depth)
        @root = Node.new(game)
        look_ahead(@root, depth)
      end

      def look_ahead(base_node, depth)
        base_node.game_status.movable_pieces_for_current_turn_color.each do |piece|
          base_node << Node.new(base_node.game_status.dup.move!(piece.location))
        end

        if (depth -= 1) > 0
          base_node.children.each do |child_node|
            look_ahead(child_node, depth)
          end
        end
      end

      def all_leaves
        @root.leaves
      end
    end

    class Node
      include Enumerable

      attr_accessor :game_status, :depth, :parent, :children, :score

      def initialize(game_status)
        @game_status = game_status
        @depth = 0
        @parent = nil
        @children = []
      end

      def add_child(node)
        node.depth = self.depth + 1
        node.parent = self
        @children << node
      end
      alias :<< :add_child

      def find_child_by_move(location)
        @children.find {|child|
          child.game_status.current_move == location
        }
      end

      def root?
        @parent.nil?
      end

      def leaf?
        return false if self.root?

        @children.empty?
      end

      def each(&block)
        if block_given?
          @children.each {|child| block.call(child) }
        else
          @children.each
        end
      end
      alias :each_children :each

      def leaves
        self.map {|child|
          child.leaf? ? child : child.leaves
        }.flatten
      end

      def postorder_traverse
        self.map {|child|
          if child.leaf?
            child.eval(self.game_status.current_turn_color)
          else
            child.score = child.postorder_traverse.max
          end
        }
      end

      def eval(color)
        @score = @game_status.score_of(color)
      end

      def inspect
        loc = @game_status.current_move || 'root'

        sprintf("<Node:: move: %s, score: %s>", loc, score)
      end
    end
  end
end
