# frozen_string_literal: true

require_relative 'list/node'

module DLinked
  # A fast, lightweight, and standards-compliant doubly linked list.
  #
  # This class provides a memory-efficient and performant alternative to Ruby's
  # standard `Array` for scenarios requiring frequent O(1) insertions or
  # deletions from the ends of the list (e.g., queues, stacks).
  #
  # It includes the `Enumerable` module, allowing it to work seamlessly with
  # standard Ruby collection methods like `map`, `select`, and `each`.
  #
  # @example Basic Usage
  #   list = DLinked::List.new
  #   list.append(20).prepend(10) # => [10, 20]
  #   list.shift # => 10
  #   list.to_a # => [20]
  class List
    include Enumerable

    # @!attribute [r] size
    #   The number of elements in the list.
    #   @return [Integer] The count of elements.
    attr_reader :size
    alias length size

    # Initializes a new, empty list.
    #
    # @example
    #   list = DLinked::List.new
    #   list.size # => 0
    def initialize
      @head = nil
      @tail = nil
      @size = 0
    end

    # --- O(1) CORE OPERATIONS ---

    # Adds a new value to the beginning of the list (the head).
    #
    # This is an **O(1)** operation.
    #
    # @example
    #   list = DLinked::List.new
    #   list.prepend(10)
    #   list.prepend(5)
    #   list.to_a # => [5, 10]
    #
    # @param value [Object] The value to store in the new node.
    # @return [self] The list instance, allowing for method chaining.
    def prepend(value)
      node = Node.new(value, nil, @head)
      list_prepend_logic(node)
    end
    alias unshift prepend

    # Adds a new value to the end of the list (the tail).
    #
    # This is an **O(1)** operation.
    #
    # @example
    #   list = DLinked::List.new
    #   list.append(10)
    #   list.append(20)
    #   list.to_a # => [10, 20]
    #
    # @param value [Object] The value to add to the list.
    # @return [self] The list instance, for method chaining.
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
    # @example
    #   list = DLinked::List.new << 1 << 2
    #   list.shift # => 1
    #   list.shift # => 2
    #   list.shift # => nil
    #
    # @return [Object, nil] The value of the removed element, or `nil` if the list is empty.
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
    # This is an **O(1)** operation.
    #
    # @example
    #   list = DLinked::List.new << 1 << 2
    #   list.pop # => 2
    #   list.pop # => 1
    #   list.pop # => nil
    #
    # @return [Object, nil] The value of the removed element, or `nil` if the list is empty.
    def pop
      return nil if empty?

      value = @tail.value
      @tail = @tail.prev
      @tail ? @tail.next = nil : @head = nil
      @size -= 1
      value
    end

    # Returns the value of the element at the head of the list without removing it.
    #
    # This is an **O(1)** operation.
    #
    # @return [Object, nil] The value of the first element, or `nil` if the list is empty.
    def first
      @head&.value
    end

    # Returns the value of the element at the tail of the list without removing it.
    #
    # This is an **O(1)** operation.
    #
    # @return [Object, nil] The value of the last element, or `nil` if the list is empty.
    def last
      @tail&.value
    end

    # Checks if the list contains any elements.
    #
    # This is an **O(1)** operation.
    #
    # @return [Boolean] `true` if the list is empty, `false` otherwise.
    def empty?
      @size.zero?
    end

    # Removes all elements from the list.
    #
    # This is an **O(1)** operation.
    #
    # @return [self] The cleared list instance.
    def clear
      @head = nil
      @tail = nil
      @size = 0
      self
    end

    # --- O(n) ENUMERATION & LOOKUP ---

    # Iterates through the list, yielding the value of each element in order from head to tail.
    #
    # This is an **O(n)** operation.
    #
    # @yield [Object] The value of the current element.
    # @return [self, Enumerator] Returns `self` if a block is given, otherwise returns an `Enumerator`.
    def each
      return enum_for(:each) unless block_given?

      current = @head
      while current
        yield current.value
        current = current.next
      end
      self
    end

    # Iterates through the list in reverse order, from tail to head.
    #
    # This is an **O(n)** operation.
    #
    # @yield [Object] The value of the current element.
    # @return [self, Enumerator] Returns `self` if a block is given, otherwise returns an `Enumerator`.
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
    # This is an **O(n)** operation.
    #
    # @param value [Object] The value to search for.
    # @return [Integer, nil] The index of the first matching element, or `nil` if not found.
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
    # This is an **O(n)** operation.
    #
    # @return [Array] A new `Array` containing all elements in order.
    def to_a
      map { |v| v }
    end

    # Returns a string representation of the list.
    #
    # This is an **O(n)** operation.
    #
    # @return [String] The string representation (e.g., `"[10, 20, 30]"`).
    def to_s
      "[#{to_a.join(', ')}]"
    end
    alias inspect to_s

    # --- O(n) ARRAY/SLICE COMPATIBILITY ---

    # @overload [](index)
    #   Retrieves the element at a specific index.
    #   Traversal is optimized to start from the head or tail, whichever is closer.
    #   @param index [Integer] The index (positive or negative).
    #   @return [Object, nil] The value at the index, or `nil` if out of bounds.
    #
    # @overload [](start, length)
    #   Retrieves a slice of `length` elements starting at `start`.
    #   @param start [Integer] The starting index.
    #   @param length [Integer] The number of elements to retrieve.
    #   @return [DLinked::List, nil] A new list containing the slice, or `nil` if `start` is out of bounds.
    #
    # @overload [](range)
    #   Retrieves a slice using a `Range`.
    #   @param range [Range] The range of indices to retrieve.
    #   @return [DLinked::List] A new list containing the slice.
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

    # @overload []=(index, value)
    #   Sets the value of an element at a single index.
    #   @param index [Integer] The index to modify.
    #   @param value [Object] The new value.
    #   @return [Object, nil] The assigned value, or `nil` if the index is out of bounds.
    #
    # @overload []=(start, length, value)
    #   Replaces a slice of `length` elements starting at `start` with a new value (or values).
    #   @param start [Integer] The starting index.
    #   @param length [Integer] The number of elements to replace.
    #   @param value [Object, Array<Object>] The new value(s).
    #   @return [Object, Array<Object>] The assigned value(s).
    #
    # @overload []=(range, value)
    #   Replaces a slice defined by a `Range` with a new value (or values).
    #   @param range [Range] The range of indices to replace.
    #   @param value [Object, Array<Object>] The new value(s).
    #   @return [Object, Array<Object>] The assigned value(s).
    def []=(*args)
      replacement = args.pop

      # 1. Handle Single Index Assignment (e.g., list[2] = 'a')
      if args.size == 1 && args[0].is_a?(Integer)
        index = args[0]
        index += @size if index.negative?
        return nil unless index >= 0 && index < @size

        node = find_node_at_index(index)
        node.value = replacement
        return replacement
      end

      # 2. Handle Slice Replacement
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

      predecessor = start_index.positive? ? find_node_at_index(start_index - 1) : nil
      current = predecessor ? predecessor.next : @head

      deleted_count = 0
      length.times do
        break unless current
        current = current.next
        deleted_count += 1
      end
      successor = current

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

      if successor
        successor.prev = insertion_point
      else
        @tail = insertion_point
      end

      replacement
    end

    # Inserts a new element at the specified index.
    #
    # This is an **O(n)** operation, unless inserting at the head (`index` = 0)
    # or tail (`index` >= `size`), in which case it is **O(1)**.
    #
    # @param index [Integer] The index before which to insert the new element.
    # @param value [Object] The value to insert.
    # @return [self] The list instance for method chaining.
    # @see #prepend
    # @see #append
    def insert(index, value)
      if index.negative?
        index += @size
        index = 0 if index.negative?
      end

      return prepend(value) if index <= 0
      return append(value) if index >= @size

      current = find_node_at_index(index)
      new_node = Node.new(value, current.prev, current)
      current.prev.next = new_node
      current.prev = new_node

      @size += 1
      self
    end

    # Deletes the *first* node that matches the given value.
    #
    # This is an **O(n)** operation.
    #
    # @param value [Object] The value to search for and delete.
    # @return [Object, nil] The value of the deleted element, or `nil` if not found.
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

    # Appends the elements of another list to this one (destructive).
    #
    # This is an **O(k)** operation, where `k` is the size of the `other` list.
    #
    # @param other [#each] An enumerable object to append.
    # @return [self] The modified list instance.
    # @raise [TypeError] if `other` is not enumerable.
    def concat(other)
      raise TypeError, "can't convert #{other.class} into DLinked::List" unless other.respond_to?(:each)
      return self if other.empty?

      other.each { |value| append(value) }
      self
    end

    # Returns a new list by concatenating this list with another (non-destructive).
    #
    # The complexity is **O(n + k)**, where `n` is the size of this list and `k`
    # is the size of the `other` list.
    #
    # @param other [#each] The enumerable object to concatenate.
    # @return [DLinked::List] A new list containing all elements from both.
    def +(other)
      new_list = self.class.new
      each { |value| new_list.append(value) }
      other.each { |value| new_list.append(value) }
      new_list
    end

    # @overload slice(index)
    #   Extracts a single element at `index` and returns it in a new list.
    #   @param index [Integer] The index to retrieve.
    #   @return [DLinked::List, nil] A new list with one element, or `nil` if out of bounds.
    #
    # @overload slice(start, length)
    #   @param start [Integer] The starting index.
    #   @param length [Integer] The number of elements in the slice.
    #   @return [DLinked::List, nil] A new list, or `nil` if `start` is out of bounds.
    #
    # @overload slice(range)
    #   @param range [Range] A range of indices.
    #   @return [DLinked::List] A new list.
    def slice(start, length = nil)
      if start.is_a?(Range) && length.nil?
        range = start
        start = range.begin
        length = range.end - range.begin + (range.exclude_end? ? 0 : 1)
      end

      start += @size if start.negative?
      return nil if start.negative? || start >= @size

      if length.nil?
        node = find_node_at_index(start)
        new_list = self.class.new
        new_list.append(node.value)
        return new_list
      end

      return List.new if length.negative?

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

    # Extracts and removes a slice of elements, returning the removed slice as a new list.
    #
    # This is an **O(n)** operation.
    #
    # @overload slice!(start, length)
    #   @param start [Integer] The starting index.
    #   @param length [Integer] The number of elements to remove.
    #   @return [DLinked::List, nil] A new list with the removed elements, or `nil` if the slice is empty.
    #
    # @overload slice!(range)
    #   @param range [Range] The range of indices to remove.
    #   @return [DLinked::List, nil] A new list with the removed elements, or `nil` if the slice is empty.
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

    # Handles the O(1) pointer logic for prepending a node.
    # @param node [DLinked::List::Node] The node to prepend.
    # @return [self]
    def list_prepend_logic(node)
      @head.prev = node if @head
      @head = node
      @tail ||= node
      @size += 1
      self
    end

    # Handles the O(1) pointer logic for appending a node.
    # @param node [DLinked::List::Node] The node to append.
    # @return [self]
    def list_append_logic(node)
      @tail.next = node if @tail
      @tail = node
      @head ||= node
      @size += 1
      self
    end

    private

    # Finds the node at a valid index using an optimized O(n/2) search.
    # @param index [Integer] The index to find.
    # @return [DLinked::List::Node] The node at the specified index.
    # @api private
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

    # Deletes a node from the list in O(1) time.
    # @param node [DLinked::List::Node] The node to delete.
    # @api private
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
