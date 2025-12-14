# frozen_string_literal: true

module DLinked
  # DLinked::CacheList
  #
  # A specialized doubly linked list subclass used as the central key management
  # component for an in-memory LRU cache.
  #
  # It integrates a hash map (`@lru_nodes`) to provide **O(1)** operations for:
  # - Prepending/Adding a new key (MRU).
  # - Touching/Moving an existing key to the head (MRU).
  # - Evicting the least recently used key (LRU).
  # - Removing an item by key.
  #
  # It maintains the standard list behavior of the superclass {DLinked::List}
  # but focuses on key-based operations rather than simple value manipulation.
  class CacheList < DLinked::List
     class Node < DLinked::List::Node
      # Add an attribute to hold the cache key
      attr_accessor :key

      # IMPORTANT: Accept the required three arguments from the base List#prepend,
      # but only initialize the base class with value, prev, and next.
      def initialize(value, prev = nil, next_node = nil, key = nil)
        # Call the parent Node initializer using the first three arguments
        super(value, prev, next_node) 
        
        # Initialize the new, specialized attribute
        @key = key
      end
    end
    # @!attribute [r] lru_nodes
    #   @return [Hash] The internal hash map storing {key => DLinked::CacheList::Node} references.
    attr_reader :lru_nodes
    # # --- 1. OVERRIDE THE CONSTANT ---
    Node = DLinked::CacheList::Node


    # Initializes a new CacheList instance.
    # @return [void]
    def initialize
      super
      @lru_nodes = {}
    end

    # --- LRU Management Methods (O(1)) ---

    # 2. Expose a key-based prepend method
    #
    # Adds a new key-value pair to the head of the list (Most Recently Used / MRU).
    # This operation is atomic, adding the node to the list and storing the
    # node reference in the internal hash map.
    #
    # @param key [Object] The cache key to be managed by the LRU list.
    # @param value [Object] The value to store inside the list node (usually the same as the key in an LRU list).
    # @raise [RuntimeError] If the key already exists in the LRU map.
    # @return [true] Returns true on successful insertion.
    def prepend_key(key, value)
      if @lru_nodes.key?(key)
        raise "Key #{key} already exists in the LRU list."
      end

      # The specialized Node creation must happen here
      node = Node.new(value, nil, @head, key) 

      # Use the base class's list logic
      list_prepend_logic(node)

      # Store the node reference in the map (O(1))
      @lru_nodes[key] = node 

      true 
    end

    # 3. Expose a key-based pop method (for eviction)
    #
    # Removes the Least Recently Used (LRU) item from the tail of the list.
    # This performs an O(1) removal and updates the internal hash map.
    #
    # @return [Object, nil] Returns the key of the removed LRU item, or nil if the list is empty.
    def pop_key
      # O(1) - Base class's pop operation on the tail node
      node = list_pop_logic 
      return nil unless node
      
      @lru_nodes.delete(node.key)
      return node.key
    end
    
    # 4. Expose the O(1) touch operation
    #
    # Moves an existing key from its current position to the head (MRU).
    # This is a core O(1) LRU "touch" operation.
    #
    # @param key [Object] The key of the item to move.
    # @return [true, false] Returns true if the move was successful, false if the key was not found.
    def move_to_head_by_key(key)
      node = @lru_nodes[key]
      return false unless node

      # Calls the internal O(1) relocation method
      _move_to_head(node) 
      true
    end

    # 5. Expose O(1) removal
    #
    # Removes an item from the list by its key.
    # This is an O(1) operation using the stored node reference.
    #
    # @param key [Object] The key of the item to remove.
    # @return [true, false] Returns true if the key was removed, false if the key was not found.
    def remove_by_key(key)
      node = @lru_nodes.delete(key)
      return false unless node
      
      # Calls the internal O(1) node deletion method
      _remove_node(node)
      true
    end

    # Clears both the doubly linked list and the internal LRU map.
    # @return [void]
    def clear
      @lru_nodes.clear
      super
    end
    
    # --- PROTECTED / INTERNAL O(1) NODE METHODS ---

    protected

    # New helper: Returns the node that was popped/shifted
    # This bypasses the base list's public #pop to allow access to the Node object.
    # @return [DLinked::CacheList::Node, nil] The node object from the tail.
    def list_pop_logic
      return nil if empty?

      node = @tail
      @tail = @tail.prev
      @tail ? @tail.next = nil : @head = nil
      @size -= 1
      return node
    end

    # O(1) Deletion from a known node reference.
    # Used internally by {#remove_by_key} and {#_move_to_head}.
    # @param node [DLinked::CacheList::Node] The node object to remove.
    # @return [Object] The value of the removed node.
    def _remove_node(node)
      # 1. Update the pointers of the surrounding nodes
      node.prev.next = node.next if node.prev
      node.next.prev = node.prev if node.next
      
      # 2. Update list head/tail if necessary
      @head = node.next if node == @head
      @tail = node.prev if node == @tail
      
      @size -= 1
      node.value
    end
    
    # O(1) Move to Head using O(1) removal and base class prepend logic.
    # @param node [DLinked::CacheList::Node] The node object to move to the head.
    # @return [void]
    def _move_to_head(node)
      return if node == @head
      
      # 1. Remove from current spot (O(1))
      _remove_node(node) 
      
      # 2. Re-establish forward link and clear backward link for clean insertion
      node.next = @head 
      node.prev = nil

      # 3. Use the base class logic to insert at head. Size counter is correct 
      #    since _remove_node decremented and list_prepend_logic increments.
      list_prepend_logic(node)
    end

  end
end
