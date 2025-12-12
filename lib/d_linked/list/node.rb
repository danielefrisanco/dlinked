# frozen_string_literal: true

module DLinked
  class List
    # The Node class represents a single element in the Doubly Linked List.
    # It holds the element's value and pointers to the next and previous nodes.
    # Note: If this class is defined outside of DLinked::List, adjust the scope accordingly.
    
    # Represents a single element within the Doubly Linked List.
    #
    # Each node maintains three critical pieces of data:
    # 1. The actual value stored by the user.
    # 2. A pointer to the next node in the list.
    # 3. A pointer to the previous node in the list.
    #
    # This structure is the foundation of the list's O(1) performance for boundary operations.
    class Node
      # @!attribute [rw] value
      #   @return [Object] The actual data stored by the user in this node.
      attr_accessor :value

      # @!attribute [rw] next
      #   @return [DLinked::List::Node, nil] A pointer to the subsequent node in the list, or nil if this is the tail.
      attr_accessor :next

      # @!attribute [rw] prev
      #   @return [DLinked::List::Node, nil] A pointer to the preceding node in the list, or nil if this is the head.
      attr_accessor :prev

      # Initializes a new Node instance.
      #
      # @param value [Object, nil] The value to store in the node.
      # @param prev [DLinked::List::Node, nil] The node preceding this one.
      # @param next_node [DLinked::List::Node, nil] The node succeeding this one.
      def initialize(value = nil, prev = nil, next_node = nil)
        @value = value
        @prev = prev
        @next = next_node
      end
    end
  end
end