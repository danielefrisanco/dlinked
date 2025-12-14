# frozen_string_literal: true

require_relative 'list/node'

module DLinked
  # A fast, lightweight doubly linked list implementation
  class List
    include Enumerable

    # PURE PERFORMANCE: We now use the dedicated Class for Node,
    # Node = DLinked::List::Node

    attr_reader :size
    alias length size

    def initialize
      @head = nil
      @tail = nil
      @size = 0
    end

    # --- O(1) CORE OPERATIONS ---

    # Adds a new value to the beginning of the list (the head).
    #
    # This is an **O(1)** operation, as it only involves updating a few pointers.
    #
    # @param value [Object] The value to store in the new node.
    # @return [self] Returns the list instance, allowing for method chaining (e.g., list.prepend(1).prepend(2)).
    def prepend(value)
      node = Node.new(value, nil, @head)
      list_prepend_logic(node)
    end
    alias unshift prepend
      
    # Adds a new value to the end of the list (the tail).
    #
    # This is an O(1) operation.
    #
    # @param value [Object] The value to add to the list.
    # @return [DLinked::List] Returns the list instance for method chaining.
    def append(value)
      node = Node.new(value, @tail, nil)
      list_append_logic(node)
    end
    alias push append
    alias << append

    # Removes the first element from the list (the head) and returns its value.
    #
    # This is an **O(1)** operation.
    #
    # @return [Object, nil] The value of the removed element, or nil if the list is empty.
    def shift
      return nil if empty?

      value = @head.value
      @head = @head.next
      @head ? @head.prev = nil : @tail = nil
      @size -= 1
      value
    end

    # Removes the last element from the list (the tail) and returns its value.
    #
    # This is an **O(1)** operation, as the tail pointer gives immediate access to the node.
    #
    # @return [Object, nil] The value of the removed element, or nil if the list is empty.
    def pop
      return nil if empty?

      value = @tail.value
      @tail = @tail.prev
      @tail ? @tail.next = nil : @head = nil
      @size -= 1
      value
    end

    # Returns the value of the element at the head (start) of the list.
    #
    # This is an **O(1)** operation.
    #
    # @return [Object, nil] The value of the first element, or nil if the list is empty.
    def first
      @head&.value
    end

    # Returns the value of the element at the tail (end) of the list.
    #
    # This is an **O(1)** operation.
    #
    # @return [Object, nil] The value of the last element, or nil if the list is empty.
    def last
      @tail&.value
    end

    # Checks if the list contains any elements.
    #
    # This is an **O(1)** operation.
    #
    # @return [Boolean] True if the size of the list is zero, false otherwise.
    def empty?
      @size.zero?
    end

    # Removes all elements from the list, resetting the head, tail, and size.
    #
    # This is an **O(1)** operation, as it only resets instance variables.
    #
    # @return [self] Returns the list instance.
    def clear
      @head = nil
      @tail = nil
      @size = 0
      self
    end

    # --- O(n) ENUMERATION & LOOKUP ---

    # Iterates through the list, yielding the value of each element in order.
    #
    # This is an **O(n)** operation, as it traverses every node from head to tail.
    #
    # @yield [Object] The value of the current element.
    # @return [self, Enumerator] Returns the list instance if a block is given, 
    #   otherwise returns an Enumerator.
    def each
      return enum_for(:each) unless block_given?

      current = @head
      while current
        yield current.value
        current = current.next
      end
      self
    end

    # Iterates through the list in reverse order, yielding the value of each element 
    # starting from the tail and moving to the head.
    #
    # This is an **O(n)** operation, as it traverses every node.
    #
    # @yield [Object] The value of the current element.
    # @return [self, Enumerator] Returns the list instance if a block is given, 
    #   otherwise returns an Enumerator.
    def reverse_each
      return enum_for(:reverse_each) unless block_given?

      current = @tail
      while current
        yield current.value
        current = current.prev
      end
      self
    end

    # Finds the index of the first occurrence of a given value.
    #
    # This is an **O(n)** operation, as it requires traversing the list from the head.
    #
    # @param value [Object] The value to search for.
    # @return [Integer, nil] The index of the first matching element, or nil if the value is not found.
    def index(value)
      current = @head
      idx = 0
      while current
        return idx if current.value == value

        current = current.next
        idx += 1
      end
      nil
    end

    # Converts the linked list into a standard Ruby Array.
    #
    # This is an **O(n)** operation, as it requires iterating over every element 
    # and allocating a new Array.
    #
    # @return [Array] A new Array containing all elements in order.
    def to_a
      map { |v| v }
    end

    # Returns a string representation of the list, resembling a standard Ruby Array.
    #
    # This is an **O(n)** operation due to the call to #to_a.
    #
    # @return [String] The string representation (e.g., "[10, 20, 30]").
    def to_s
      "[#{to_a.join(', ')}]"
    end
    alias inspect to_s

    # --- O(n) ARRAY/SLICE COMPATIBILITY ---

    # Retrieves the element(s) at the specified index or within a slice.
    #
    # This method supports two primary forms of access:
    # 1. **Single Index (O(n)):** Returns the element at a specific positive or negative index (e.g., list[2] or list[-1]).
    # 2. **Slice Access (O(n)):** Delegates to the {#slice} method for start/length or range access (e.g., list[1, 2] or list[1..3]).
    #
    # Traversal is optimized: for positive indices less than size/2, traversal starts from the head; 
    # otherwise, it starts from the tail.
    #
    # @param args [Array] Arguments representing either a single index or slice parameters:
    #   - `(index)` for single element access.
    #   - `(start_index, length)` for a slice.
    #   - `(range)` for a slice using a Range object.
    # @return [Object, Array<Object>, nil] The value at the index, an array of values for a slice, or nil if the single index is out of bounds.
    def [](*args)
      # Case 1: Single Index Access (list[i])
      if args.size == 1 && args[0].is_a?(Integer)
        index = args[0]
        index += @size if index.negative?
        return nil if index.negative? || index >= @size

        node = find_node_at_index(index)
        return node.value # Returns raw value
      end

      # Case 2 & 3: Slicing (list[start, length] or list[range])
      slice(*args) # Delegate to the robust slice method
    end

    # Sets the value of an element at a single index or replaces a slice (range or start/length) 
    # with new element(s).
    #
    # This method handles four main scenarios:
    # 1. Single Element Assignment (O(n)): Overwrites the value at a valid index.
    # 2. Slice Replacement (O(n)): Deletes a section and inserts new elements.
    # 3. Out-of-Bounds Append (O(k)): If the start index is greater than the current size, 
    #    the new elements are appended to the list (k is the length of the replacement).
    # 4. Out-of-Bounds Non-Append (Returns nil): For a single index assignment that is out of bounds, 
    #    it returns nil (like a standard Ruby Array setter).
    #
    # The overall complexity is **O(n + k)**, where n is the traversal time to find the start point, 
    # and k is the number of elements being inserted or deleted.
    #
    # @param args [Array] The arguments defining the assignment. The last element of this array 
    #   is always the replacement value.
    #   - `(index, replacement)` for single assignment.
    #   - `(start_index, length, replacement)` for slice replacement.
    #   - `(range, replacement)` for range replacement.
    # @return [Object, Array, nil] The value(s) assigned, or nil if the assignment failed 
    #   due to an invalid out-of-bounds single index.
    def []=(*args)
      replacement = args.pop

      # 1. Handle Single Index Assignment (e.g., list[2] = 'a')
      if args.size == 1 && args[0].is_a?(Integer)
        index = args[0]
        index += @size if index.negative?
        # Check bounds for simple assignment (Must be within 0 to size-1)
        return nil unless index >= 0 && index < @size

        # Simple assignment: O(n) lookup, O(1) set
        node = find_node_at_index(index)
        node.value = replacement
        return replacement

        # For out-of-bounds, Array compatibility is usually IndexError, but
        # based on your design, we return nil

      end

      # 2. Handle Slice Replacement (list[2, 3] = [a, b] or list[2..4] = [a, b])
      start_index, length = *args

      if args.size == 1 && start_index.is_a?(Range)
        range = start_index
        start_index = range.begin
        length = range.end - range.begin + (range.exclude_end? ? 0 : 1)
      elsif args.size != 2 || !start_index.is_a?(Integer) || !length.is_a?(Integer)
        return nil
      end

      start_index += @size if start_index.negative?

      if start_index > @size
        replacement = Array(replacement)
        replacement.each { |val| append(val) }
        return replacement
      end

      replacement = Array(replacement)

      # Find Boundaries
      predecessor = start_index.positive? ? find_node_at_index(start_index - 1) : nil
      current = predecessor ? predecessor.next : @head

      deleted_count = 0
      length.times do
        break unless current

        current = current.next
        deleted_count += 1
      end
      successor = current

      # Stage 1: DELETION (Relink the neighbors)
      if predecessor
        predecessor.next = successor
      else
        @head = successor
      end

      if successor
        successor.prev = predecessor
      else
        @tail = predecessor
      end
      @size -= deleted_count

      # Stage 2: INSERTION (Insert new nodes at the boundary)
      insertion_point = predecessor
      replacement.each do |value|
        new_node = Node.new(value, insertion_point, successor)

        if insertion_point
          insertion_point.next = new_node
        else
          @head = new_node
        end

        insertion_point = new_node
        @size += 1
      end

      # Stage 3: FINAL RELINKING (The last inserted node links back to the successor)
      if successor
        successor.prev = insertion_point
      else
        @tail = insertion_point
      end

      replacement # Return the set values
    end

    # Inserts a new element at the specified index.
    #
    # If the index is 0, this is equivalent to {#prepend} (O(1)).
    # If the index is equal to or greater than the size, this is equivalent to {#append} (O(1)).
    # For all other valid indices, this is an **O(n)** operation as it requires traversal 
    # to find the insertion point.
    #
    # Supports negative indices, where list.insert(-1, value) inserts before the last element.
    #
    # @param index [Integer] The index before which the new element should be inserted.
    # @param value [Object] The value to be inserted.
    # @return [DLinked::List] Returns the list instance for method chaining.
    def insert(index, value)
      if index.negative?
        index += @size
        index = 0 if index.negative?
      end

      return prepend(value) if index <= 0
      return append(value) if index >= @size

      # Find the node to insert BEFORE
      current = find_node_at_index(index)

      new_node = Node.new(value, current.prev, current)

      # Insert before current node (O(1) linking)
      current.prev.next = new_node
      current.prev = new_node

      @size += 1
      self
    end

    # Deletes the *first* node that matches the given value and returns the value of the deleted element.
    #
    # This is an **O(n)** operation because it requires traversal to find the node. 
    # However, once the node is found, the relinking operation is O(1).
    #
    # @param value [Object] The value to search for and delete.
    # @return [Object, nil] The value of the deleted element, or nil if the value was not found in the list.
    def delete(value)
      current = @head
      while current
        if current.value == value
          delete_node(current)
          return value
        end
        current = current.next
      end
      nil
    end

    # Concatenates the elements of another DLinked::List to the end of this list, modifying the current list.
    #
    # This is an **O(n)** operation, where n is the size of the *other* list, as it must traverse and link
    # every element of the other list into the current list structure.
    #
    # @param other [DLinked::List] The list whose elements will be appended.
    # @return [self] Returns the modified list instance.
    def concat(other)
      raise TypeError, "can't convert #{other.class} into DLinked::List" unless other.respond_to?(:each)
      return self if other.empty?

      other.each { |value| append(value) }
      self
    end

    # Returns a new DLinked::List that is the concatenation of this list and another list.
    #
    # This is a non-destructive operation, meaning neither the current list nor the other list is modified.
    # The complexity is **O(n + k)**, where n is the size of the current list and k is the size of the other list, 
    # as both must be traversed and copied into the new list.
    #
    # @param other [DLinked::List] The list to append to this one.
    # @return [DLinked::List] A new list containing all elements from both lists.
    def +(other)
      new_list = self.class.new
      each { |value| new_list.append(value) }
      other.each { |value| new_list.append(value) }
      new_list
    end

    # Extracts a slice of elements from the list, returning a new DLinked::List instance.
    #
    # Supports slicing via:
    # 1. Start index and length (e.g., list.slice(1, 2))
    # 2. Range (e.g., list.slice(1..3))
    #
    # This is an **O(n)** operation, where n is the traversal time to find the start point, 
    # plus the time to copy the slice elements into a new list.
    #
    # @param start [Integer, Range] The starting index or a Range object defining the slice.
    # @param length [Integer, nil] The number of elements to include in the slice.
    # @return [DLinked::List, nil] A new list containing the sliced elements, or nil if the slice is out of bounds.
    def slice(start, length = nil)
      # Handle Range Argument
      if start.is_a?(Range) && length.nil?
        range = start
        start = range.begin
        length = range.end - range.begin + (range.exclude_end? ? 0 : 1)
      end

      # 1. Resolve start index (including negative indices)
      start += @size if start.negative?

      return nil if start.negative? || start >= @size

      if length.nil?
        node = find_node_at_index(start)
        new_list = self.class.new
        new_list.append(node.value)
        return new_list # Returns DLinked::List: [value]
      end

      # Handle negative length returning nil
      return nil if length.negative?
      return List.new if length.zero?

      new_list = List.new
      current = find_node_at_index(start)

      count = 0
      while current && count < length
        new_list.append(current.value)
        current = current.next
        count += 1
      end

      new_list
    end

    # Extracts and removes a slice of elements from the list, returning a new list 
    # containing the removed elements.
    #
    # Supports destructive slicing via:
    # 1. Start index and length (e.g., list.slice!(1, 2))
    # 2. Range (e.g., list.slice!(1..3))
    #
    # The complexity is **O(n + k)**, where n is the traversal time to find the start point, 
    # and k is the number of elements removed/copied.
    #
    # @param args [Array] Arguments representing the slice: (start_index, length) or (range).
    # @return [DLinked::List, nil] A new list containing the extracted and removed elements, 
    #   or nil if the slice is empty or invalid.
    def slice!(*args)
      start_index, length = *args

      if args.size == 1 && start_index.is_a?(Range)
        range = start_index
        start_index = range.begin
        length = range.end - range.begin + (range.exclude_end? ? 0 : 1)
      elsif args.size == 1
        length = 1
      elsif args.size != 2 || length < 1
        return nil
      end

      start_index += @size if start_index.negative?

      return nil if start_index >= @size || length <= 0

      predecessor = start_index.positive? ? find_node_at_index(start_index - 1) : nil
      current = predecessor ? predecessor.next : @head

      length.times do
        break unless current

        current = current.next
      end
      successor = current

      result = self.class.new
      slice_node = predecessor ? predecessor.next : @head

      if predecessor
        predecessor.next = successor
      else
        @head = successor
      end

      if successor
        successor.prev = predecessor
      else
        @tail = predecessor
      end

      removed_count = 0
      while slice_node != successor
        next_node = slice_node.next
        result.append(slice_node.value)
        slice_node.prev = nil
        slice_node.next = nil
        slice_node = next_node
        removed_count += 1
      end

      @size -= removed_count
      result.empty? ? nil : result
    end
    protected

    # This method handles the actual pointer manipulation, which is constant across all subclasses
    def list_prepend_logic(node)
      @head.prev = node if @head
      @head = node
      @tail ||= node
      @size += 1
      self
    end

    def list_append_logic(node)
      @tail.next = node if @tail
      @tail = node
      @head ||= node
      @size += 1
      self
    end

    private

    # O(n/2) - Internal helper method to find the node at a valid index.
    def find_node_at_index(index)
      # Optimization: Start from head or tail, whichever is closer
      if index <= @size / 2
        current = @head
        index.times { current = current.next }
      else
        current = @tail
        (@size - 1 - index).times { current = current.prev }
      end
      current
    end

    # O(1) - Internal method to delete a specific node
    def delete_node(node)
      if node.prev
        node.prev.next = node.next
      else
        @head = node.next
      end

      if node.next
        node.next.prev = node.prev
      else
        @tail = node.prev
      end

      @size -= 1
    end
  end
end
