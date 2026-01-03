# frozen_string_literal: true

module DLinked
  # A specialized doubly linked list for managing keys in a Least Recently Used (LRU) cache.
  #
  # This class extends {DLinked::List} by integrating a `Hash` map (`@lru_nodes`)
  # to provide **O(1)** time complexity for all critical cache operations:
  # adding, accessing (touching), evicting, and removing keys.
  #
  # The list maintains items in order from Most Recently Used (MRU) at the
  # head to Least Recently Used (LRU) at the tail.
  #
  # @example Implementing a simple LRU Cache
  #   class MyLRUCache
  #     def initialize(capacity)
  #       @capacity = capacity
  #       @list = DLinked::CacheList.new
  #       @data = {}
  #     end
  #
  #     def get(key)
  #       return nil unless @data.key?(key)
  #       @list.move_to_head_by_key(key) # Mark as recently used
  #       @data[key]
  #     end
  #
  #     def set(key, value)
  #       if @data.key?(key)
  #         @list.move_to_head_by_key(key)
  #       else
  #         @list.prepend_key(key, value)
  #         evict if @list.size > @capacity
  #       end
  #       @data[key] = value
  #     end
  #
  #     private
  #
  #     def evict
  #       lru_key = @list.pop_key
  #       @data.delete(lru_key)
  #     end
  #   end
  class CacheList < DLinked::List
    # A specialized node for the `CacheList` that includes a `key`.
    class Node < DLinked::List::Node
      # @!attribute [rw] key
      #   @return [Object] The cache key associated with this node.
      attr_accessor :key

      # Initializes a new CacheList Node.
      # @param value [Object] The value to store in the node.
      # @param prev [Node, nil] The preceding node.
      # @param next_node [Node, nil] The succeeding node.
      # @param key [Object] The cache key for this node.
      def initialize(value, prev = nil, next_node = nil, key = nil)
        super(value, prev, next_node)
        @key = key
      end
    end

    # @!attribute [r] lru_nodes
    #   @return [Hash{Object => DLinked::CacheList::Node}] The internal hash map.
    attr_reader :lru_nodes

    # Initializes a new, empty `CacheList`.
    def initialize
      super
      @lru_nodes = {}
    end

    # --- LRU Management Methods (O(1)) ---

    # Adds a new key-value pair to the head of the list (making it the MRU item).
    #
    # This is an **O(1)** operation.
    #
    # @example
    #   lru = DLinked::CacheList.new
    #   lru.prepend_key(:a, 1)
    #   lru.to_a # => [1]
    #
    # @param key [Object] The cache key.
    # @param value [Object] The value to store in the list node.
    # @raise [RuntimeError] If the key already exists.
    # @return [true] `true` on successful insertion.
    def prepend_key(key, value)
      raise "Key #{key} already exists in the LRU list." if @lru_nodes.key?(key)

      node = Node.new(value, nil, @head, key)
      list_prepend_logic(node) # Use base class's logic
      @lru_nodes[key] = node
      true
    end

    # Removes the Least Recently Used (LRU) item from the tail of the list.
    #
    # This is an **O(1)** operation.
    #
    # @example
    #   lru = DLinked::CacheList.new
    #   lru.prepend_key(:a, 1)
    #   lru.prepend_key(:b, 2) # List is now [:b, :a]
    #   lru.pop_key # => :a
    #
    # @return [Object, nil] The key of the removed LRU item, or `nil` if the list is empty.
    def pop_key
      node = list_pop_logic
      return nil unless node

      @lru_nodes.delete(node.key)
      node.key
    end

    # Moves an existing key from its current position to the head (making it the MRU item).
    # This is a core "touch" operation for an LRU cache.
    #
    # This is an **O(1)** operation.
    #
    # @example
    #   lru = DLinked::CacheList.new
    #   lru.prepend_key(:a, 1)
    #   lru.prepend_key(:b, 2) # List order: [:b, :a]
    #   lru.move_to_head_by_key(:a) # "touch" :a
    #   lru.to_a # => [1, 2] (node values), key order is now [:a, :b]
    #
    # @param key [Object] The key of the item to move.
    # @return [true, false] `true` if the move was successful, `false` if the key was not found.
    def move_to_head_by_key(key)
      node = @lru_nodes[key]
      return false unless node

      _move_to_head(node)
      true
    end

    # Removes an item from the list and map by its key.
    #
    # This is an **O(1)** operation.
    #
    # @example
    #   lru = DLinked::CacheList.new
    #   lru.prepend_key(:a, 1)
    #   lru.remove_by_key(:a) # => true
    #   lru.empty? # => true
    #
    # @param key [Object] The key of the item to remove.
    # @return [true, false] `true` if removed, `false` if the key was not found.
    def remove_by_key(key)
      node = @lru_nodes.delete(key)
      return false unless node

      _remove_node(node)
      true
    end

    # Clears the list and the internal key map.
    #
    # This is an **O(1)** operation.
    #
    # @return [self]
    def clear
      @lru_nodes.clear
      super
    end

    # --- PROTECTED / INTERNAL O(1) NODE METHODS ---

    protected

    # Pops the tail node and returns the full node object.
    # @return [DLinked::CacheList::Node, nil] The node from the tail.
    # @api protected
    def list_pop_logic
      return nil if empty?

      node = @tail
      @tail = @tail.prev
      @tail ? @tail.next = nil : @head = nil
      @size -= 1
      node
    end

    # Deletes a given node reference in O(1) time.
    # @param node [DLinked::CacheList::Node] The node object to remove.
    # @return [Object] The value of the removed node.
    # @api protected
    def _remove_node(node)
      node.prev.next = node.next if node.prev
      node.next.prev = node.prev if node.next

      @head = node.next if node == @head
      @tail = node.prev if node == @tail

      @size -= 1
      node.value
    end

    # Moves a given node reference to the head in O(1) time.
    # @param node [DLinked::CacheList::Node] The node object to move.
    # @api protected
    def _move_to_head(node)
      return if node == @head

      _remove_node(node)
      node.next = @head
      node.prev = nil
      list_prepend_logic(node)
    end
  end
end
