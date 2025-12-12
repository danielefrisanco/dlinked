# frozen_string_literal: true
require_relative "list/node"
module DLinked
  # A fast, lightweight doubly linked list implementation
  class List
    include Enumerable

    # PURE PERFORMANCE: We now use the dedicated Class for Node,
    Node = DLinked::List::Node
    private_constant :Node

    attr_reader :size
    alias_method :length, :size

    def initialize
      @head = nil
      @tail = nil
      @size = 0
    end

    # --- O(1) CORE OPERATIONS ---
    
    # O(1) - Add element to the front
    def prepend(value)
      node = Node.new(value, nil, @head)
      @head.prev = node if @head
      @head = node
      @tail ||= node
      @size += 1
      self
    end
    alias_method :unshift, :prepend
    
    # O(1) - Add element to the end
    def append(value)
      node = Node.new(value, @tail, nil)
      @tail.next = node if @tail
      @tail = node
      @head ||= node
      @size += 1
      self
    end
    alias_method :push, :append
    alias_method :<<, :append

    # O(1) - Remove and return first element
    def shift
      return nil if empty?
      value = @head.value
      @head = @head.next
      @head ? @head.prev = nil : @tail = nil
      @size -= 1
      value
    end

    # O(1) - Remove and return last element
    def pop
      return nil if empty?
      value = @tail.value
      @tail = @tail.prev
      @tail ? @tail.next = nil : @head = nil
      @size -= 1
      value
    end

    # O(1) - Get first element without removing
    def first
      @head&.value
    end

    # O(1) - Get last element without removing
    def last
      @tail&.value
    end

    # O(1) - Check if list is empty
    def empty?
      @size.zero?
    end
    
    # O(1) - Clear all elements
    def clear
      @head = nil
      @tail = nil
      @size = 0
      self
    end

    # --- O(n) ENUMERATION & LOOKUP ---
    
    # O(n) - Iterate over elements
    def each
      return enum_for(:each) unless block_given?
      current = @head
      while current
        yield current.value
        current = current.next
      end
      self
    end

    # O(n) - Iterate in reverse
    def reverse_each
      return enum_for(:reverse_each) unless block_given?
      current = @tail
      while current
        yield current.value
        current = current.prev
      end
      self
    end
    
    # O(n) - Find index of element
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
    
    # O(n) - Convert to array
    def to_a
      map { |v| v }
    end

    # O(n) - String representation
    def to_s
      "[#{to_a.join(', ')}]"
    end
    alias_method :inspect, :to_s

    # --- O(n) ARRAY/SLICE COMPATIBILITY ---

    # O(n) - Access element by index or slice (getter)
    # Handles: list[index] (returns value), list[start, length], list[range] (returns List)
    def [](*args)
      # Case 1: Single Index Access (list[i])
      if args.size == 1 && args[0].is_a?(Integer)
        index = args[0]
        index += @size if index < 0
        return nil if index < 0 || index >= @size
        
        node = find_node_at_index(index)
        return node.value # Returns raw value
      end
      
      # Case 2 & 3: Slicing (list[start, length] or list[range])
      slice(*args) # Delegate to the robust slice method
    end

    # O(n) - Set element at index or replace a slice (setter)
    def []=(*args)
      replacement = args.pop 
      
      # 1. Handle Single Index Assignment (e.g., list[2] = 'a')
      if args.size == 1 && args[0].is_a?(Integer)
        index = args[0]
        index += @size if index < 0
        # Check bounds for simple assignment (Must be within 0 to size-1)
        if index >= 0 && index < @size
          # Simple assignment: O(n) lookup, O(1) set
          node = find_node_at_index(index)
          node.value = replacement
          return replacement
        else
          # For out-of-bounds, Array compatibility is usually IndexError, but 
          # based on your design, we return nil
          return nil 
        end
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
      
      start_index += @size if start_index < 0
      
      if start_index > @size
        replacement = Array(replacement)
        replacement.each { |val| append(val) }
        return replacement
      end
      
      replacement = Array(replacement) 
      
      # Find Boundaries
      predecessor = start_index > 0 ? find_node_at_index(start_index - 1) : nil
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

    # O(n) - Insert element at index
    def insert(index, value)
      if index < 0
        index += @size
        index = 0 if index < 0
      end
      
      return prepend(value) if index <= 0 
      return append(value) if index >= @size 
      
      current = find_node_at_index(index)
      
      # Insert before current node (O(1) linking)
      new_node = Node.new(value, current.prev, current)
      current.prev.next = new_node 
      current.prev = new_node
      
      @size += 1
      self
    end
    
    # O(n) - Delete first occurrence of value
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

    # O(n) - Concatenate another list to the end (modifies self)
    def concat(other)
      unless other.respond_to?(:each)
        raise TypeError, "can't convert #{other.class} into DLinked::List"
      end
      return self if other.empty?
      other.each { |value| append(value) }
      self
    end

    # O(n) - Concatenate and return new list (non-destructive)
    def +(other)
      new_list = self.class.new
      each { |value| new_list.append(value) }
      other.each { |value| new_list.append(value) }
      new_list
    end

    # O(n) - Extract a slice (returns new list)
    def slice(start, length = nil)
      # Handle Range Argument
      if start.is_a?(Range) && length.nil?
        range = start
        start = range.begin
        length = range.end - range.begin + (range.exclude_end? ? 0 : 1)
      end
      
      # 1. Resolve start index (including negative indices)
      start += @size if start < 0
      
      return nil if start < 0 || start >= @size
      
      if length.nil?
        node = find_node_at_index(start) 
        new_list = self.class.new
        new_list.append(node.value)
        return new_list # Returns DLinked::List: [value]
      end
      
      # Handle negative length returning nil
      return nil if length < 0
      return List.new if length == 0
      
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

    # O(n) - Extract and remove a slice (destructive)
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
      
      start_index += @size if start_index < 0
      
      return nil if start_index >= @size || length <= 0
      
      predecessor = start_index > 0 ? find_node_at_index(start_index - 1) : nil
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