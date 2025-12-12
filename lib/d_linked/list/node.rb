# frozen_string_literal: true

module DLinked
  class List
    # The Node class, defined here for encapsulation and performance.
    class Node
      # Uses attr_accessor to achieve the same data-storage function as Struct,
      # but with the performance benefits observed in the benchmark.
      attr_accessor :value, :prev, :next

      # Custom initialize method to mimic the Struct's simplicity.
      def initialize(value, prev, next_node)
        @value = value
        @prev = prev
        @next = next_node
      end
    end
  end
end