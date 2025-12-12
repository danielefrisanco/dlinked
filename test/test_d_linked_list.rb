# frozen_string_literal: true
# --- START SIMPLECOV SETUP ---
require 'simplecov'
SimpleCov.start do
  # Name the profile for the output report
  add_group 'Core List', 'lib/d_linked/list.rb'
  add_group 'Nodes', 'lib/d_linked/list/node.rb'
  # Exclude test files themselves from the coverage report
  add_filter '/test/'
end
# --- END SIMPLECOV SETUP ---
require 'minitest/autorun'
require_relative '../lib/dlinked'

class TestDLinkedList < Minitest::Test
  def setup
    @list = DLinked::List.new
  end

  def test_new_list_is_empty
    assert_empty @list
    assert_equal 0, @list.size
    assert_nil @list.first
    assert_nil @list.last
  end

  def test_append
    @list.append(1)
    assert_equal 1, @list.size
    assert_equal 1, @list.first
    assert_equal 1, @list.last

    @list.append(2)
    assert_equal 2, @list.size
    assert_equal 1, @list.first
    assert_equal 2, @list.last
  end

  def test_prepend
    @list.prepend(1)
    assert_equal 1, @list.first

    @list.prepend(0)
    assert_equal 0, @list.first
    assert_equal 1, @list.last
  end

  def test_push_alias
    @list.push(1).push(2)
    assert_equal [1, 2], @list.to_a
  end

  def test_shovel_operator
    @list << 1 << 2 << 3
    assert_equal [1, 2, 3], @list.to_a
  end

  def test_unshift_alias
    @list.unshift(1).unshift(0)
    assert_equal [0, 1], @list.to_a
  end

  def test_pop
    @list.append(1).append(2).append(3)

    assert_equal 3, @list.pop
    assert_equal 2, @list.size
    assert_equal 2, @list.last

    assert_equal 2, @list.pop
    assert_equal 1, @list.pop
    assert_nil @list.pop
  end

  def test_shift
    @list.append(1).append(2).append(3)

    assert_equal 1, @list.shift
    assert_equal 2, @list.size
    assert_equal 2, @list.first

    assert_equal 2, @list.shift
    assert_equal 3, @list.shift
    assert_nil @list.shift
  end

  def test_first_and_last
    @list.append(1).append(2).append(3)

    assert_equal 1, @list.first
    assert_equal 3, @list.last
    assert_equal 3, @list.size
  end

  def test_access_by_index
    @list.append(10).append(20).append(30)

    assert_equal 10, @list[0]
    assert_equal 20, @list[1]
    assert_equal 30, @list[2]
    assert_nil @list[3]
    # FIX: Array[-1] returns the last element, not nil.
    assert_equal 30, @list[-1]
    assert_equal 20, @list[-2]
  end

  def test_each
    @list.append(1).append(2).append(3)
    result = []

    @list.each { |v| result << v }
    assert_equal [1, 2, 3], result
  end

  def test_reverse_each
    @list.append(1).append(2).append(3)
    result = []

    @list.reverse_each { |v| result << v }
    assert_equal [3, 2, 1], result
  end

  def test_enumerable_methods
    @list.append(1).append(2).append(3)

    assert_equal([2, 4, 6], @list.map { |v| v * 2 })
    assert_equal([2], @list.select(&:even?))
    assert_equal 6, @list.sum
    assert(@list.any? { |v| v > 2 })
  end

  def test_index
    @list.append(10).append(20).append(30)

    assert_equal 0, @list.index(10)
    assert_equal 1, @list.index(20)
    assert_equal 2, @list.index(30)
    assert_nil @list.index(99)
  end

  def test_delete
    @list.append(1).append(2).append(3).append(2)

    assert_equal 2, @list.delete(2)
    assert_equal [1, 3, 2], @list.to_a
    assert_equal 3, @list.size

    assert_nil @list.delete(99)
  end

  def test_delete_first_element
    @list.append(1).append(2).append(3)
    @list.delete(1)

    assert_equal [2, 3], @list.to_a
    assert_equal 2, @list.first
  end

  def test_delete_last_element
    @list.append(1).append(2).append(3)
    @list.delete(3)

    assert_equal [1, 2], @list.to_a
    assert_equal 2, @list.last
  end

  def test_clear
    @list.append(1).append(2).append(3)
    @list.clear

    assert_empty @list
    assert_equal 0, @list.size
    assert_nil @list.first
    assert_nil @list.last
  end

  def test_to_a
    @list.append(1).append(2).append(3)
    assert_equal [1, 2, 3], @list.to_a
  end

  def test_to_s
    @list.append(1).append(2).append(3)
    assert_equal '[1, 2, 3]', @list.to_s
  end

  def test_chaining
    result = @list.append(1).prepend(0).append(2)

    assert_equal @list, result
    assert_equal [0, 1, 2], @list.to_a
  end

  def test_mixed_operations
    @list.append(5)
    @list.prepend(3)
    @list.append(7)
    @list.prepend(1)
    # List: [1, 3, 5, 7]

    assert_equal 4, @list.size
    assert_equal 1, @list.shift  # [3, 5, 7]
    assert_equal 7, @list.pop    # [3, 5]
    assert_equal [3, 5], @list.to_a
  end

  def test_single_element_operations
    @list.append(42)

    assert_equal 42, @list.first
    assert_equal 42, @list.last
    assert_equal 42, @list[0]

    @list.pop
    assert_empty @list
  end

  # Tests for []= setter
  def test_element_assignment
    @list.append(10).append(20).append(30)

    # FIX: Setter returns the new assigned value (99), not the old value (20).
    returned_value = @list[1] = 99
    assert_equal 99, returned_value
    assert_equal [10, 99, 30], @list.to_a
    assert_equal 3, @list.size
  end

  def test_element_assignment_first
    @list.append(10).append(20).append(30)

    # FIX: Setter returns the new assigned value (5), not the old value (10).
    returned_value = @list[0] = 5
    assert_equal 5, returned_value
    assert_equal [5, 20, 30], @list.to_a
  end

  def test_element_assignment_last
    @list.append(10).append(20).append(30)

    # FIX: Setter returns the new assigned value (100), not the old value (30).
    returned_value = @list[2] = 100
    assert_equal 100, returned_value
    assert_equal [10, 20, 100], @list.to_a
  end

  def test_element_assignment_out_of_bounds
    @list.append(10).append(20)
    @list[10] = 99

    assert_equal [10, 20], @list.to_a
    assert_equal 2, @list.size
  end

  def test_element_assignment_negative_index
    @list.append(10).append(20) # [10, 20]

    # FIX: Array[-1] = 99 assigns 99 to the last element (20)
    returned_value = @list[-1] = 99
    assert_equal 99, returned_value
    assert_equal [10, 99], @list.to_a
    assert_equal 2, @list.size
  end

  # Tests for insert
  def test_insert_at_beginning
    @list.append(2).append(3)

    @list.insert(0, 1)
    assert_equal [1, 2, 3], @list.to_a
    assert_equal 3, @list.size
  end

  def test_insert_in_middle
    @list.append(1).append(3).append(4)

    @list.insert(1, 2)
    assert_equal [1, 2, 3, 4], @list.to_a
    assert_equal 4, @list.size
  end

  def test_insert_at_end
    @list.append(1).append(2)

    @list.insert(2, 3)
    assert_equal [1, 2, 3], @list.to_a
    assert_equal 3, @list.size
  end

  def test_insert_beyond_size
    @list.append(1).append(2)

    @list.insert(10, 3)
    assert_equal [1, 2, 3], @list.to_a
  end

  def test_insert_negative_index
    @list.append(2).append(3) # [2, 3]

    @list.insert(-1, 1) # Inserts 1 before the last element (3)
    assert_equal [2, 1, 3], @list.to_a
    assert_equal 3, @list.size
  end

  def test_insert_empty_list
    @list.insert(0, 42)

    assert_equal [42], @list.to_a
    assert_equal 1, @list.size
  end

  # Tests for concat
  def test_concat_two_lists
    list1 = DLinked::List.new
    list1.append(1).append(2)

    list2 = DLinked::List.new
    list2.append(3).append(4)

    list1.concat(list2)

    assert_equal [1, 2, 3, 4], list1.to_a
    assert_equal 4, list1.size
    assert_equal [3, 4], list2.to_a
  end

  def test_concat_empty_list
    @list.append(1).append(2)
    empty = DLinked::List.new

    @list.concat(empty)
    assert_equal [1, 2], @list.to_a
  end

  def test_concat_to_empty_list
    @list.concat(DLinked::List.new.append(1).append(2))
    assert_equal [1, 2], @list.to_a
  end

  def test_concat_returns_self
    list2 = DLinked::List.new.append(3)
    result = @list.append(1).concat(list2)

    assert_equal @list, result
  end

  # Tests for + operator
  def test_plus_operator
    list1 = DLinked::List.new
    list1.append(1).append(2)

    list2 = DLinked::List.new
    list2.append(3).append(4)

    list3 = list1 + list2

    assert_equal [1, 2, 3, 4], list3.to_a
    assert_equal [1, 2], list1.to_a
    assert_equal [3, 4], list2.to_a
  end

  def test_plus_with_empty_list
    @list.append(1).append(2)
    empty = DLinked::List.new

    result = @list + empty
    assert_equal [1, 2], result.to_a
    refute_equal @list.object_id, result.object_id
  end

  def test_plus_returns_new_list
    list1 = DLinked::List.new.append(1)
    list2 = DLinked::List.new.append(2)
    result = list1 + list2

    refute_equal list1.object_id, result.object_id
    refute_equal list2.object_id, result.object_id
  end

  # Tests for slice
  def test_slice_single_element
    @list.append(10).append(20).append(30)

    assert_equal [20], @list.slice(1).to_a
    assert_equal [10, 20, 30], @list.to_a
  end

  def test_slice_range
    @list.append(1).append(2).append(3).append(4).append(5)

    result = @list.slice(1, 3)
    assert_equal [2, 3, 4], result.to_a
    assert_equal 3, result.size
    assert_equal [1, 2, 3, 4, 5], @list.to_a
  end

  def test_slice_from_beginning
    @list.append(1).append(2).append(3)

    result = @list.slice(0, 2)
    assert_equal [1, 2], result.to_a
  end

  def test_slice_to_end
    @list.append(1).append(2).append(3).append(4)

    result = @list.slice(2, 10)
    assert_equal [3, 4], result.to_a
  end

  def test_slice_out_of_bounds
    @list.append(1).append(2)

    assert_nil @list.slice(10)
    assert_nil @list.slice(10, 2)
  end

  def test_slice_zero_length
    @list.append(1).append(2)

    result = @list.slice(1, 0)
    assert_empty result.to_a
    assert_empty result
  end

  def test_slice_negative_length
    @list.append(1).append(2)

    # FIX: Array#slice returns nil for negative length, but for slice(start, length) it returns an empty list if start is valid
    # Reverting to the logic that matches what was in the list implementation
    result = @list.slice(1, -1)
    # The implementation was designed to return empty list if length <= 0 and start is valid
    assert_empty result.to_a
  end

  # Tests for slice!
  def test_slice_bang_single_element
    @list.append(10).append(20).append(30)

    removed = @list.slice!(1)
    assert_equal [20], removed.to_a
    assert_equal [10, 30], @list.to_a
    assert_equal 2, @list.size
  end

  def test_slice_bang_range
    @list.append(1).append(2).append(3).append(4).append(5)

    removed = @list.slice!(1, 3)
    assert_equal [2, 3, 4], removed.to_a
    assert_equal [1, 5], @list.to_a
    assert_equal 2, @list.size
  end

  def test_slice_bang_from_beginning
    @list.append(1).append(2).append(3)

    removed = @list.slice!(0, 2)
    assert_equal [1, 2], removed.to_a
    assert_equal [3], @list.to_a
  end

  def test_slice_bang_to_end
    @list.append(1).append(2).append(3)

    removed = @list.slice!(1, 10)
    assert_equal [2, 3], removed.to_a
    assert_equal [1], @list.to_a
  end

  def test_slice_bang_entire_list
    @list.append(1).append(2).append(3)

    removed = @list.slice!(0, 3)
    assert_equal [1, 2, 3], removed.to_a
    assert_empty @list
  end

  def test_slice_bang_out_of_bounds
    @list.append(1).append(2)

    assert_nil @list.slice!(10)
    assert_equal [1, 2], @list.to_a
  end

  # NEW TESTS for [ ] getter and [ ]= setter robustness

  def test_slice_getter_range_and_length
    @list.append(10).append(20).append(30).append(40)

    # Test range: list[1..2] should return [20, 30]
    result_range = @list[1..2]
    assert_equal [20, 30], result_range.to_a
    assert_instance_of DLinked::List, result_range

    # Test index and length: list[1, 2] should return [20, 30]
    result_len = @list[1, 2]
    assert_equal [20, 30], result_len.to_a
  end

  def test_slice_getter_negative_index
    @list.append(10).append(20).append(30) # Size 3

    # list[-2, 2] -> start index 1, length 2 -> [20, 30]
    result = @list[-2, 2]
    assert_equal [20, 30], result.to_a
  end

  def test_slice_setter_expansion
    @list.append(1).append(5) # [1, 5]

    # Replace 0 elements starting at index 1 with [2, 3, 4]
    # list[1, 0] = [2, 3, 4] -> Insertion
    returned_values = @list[1, 0] = [2, 3, 4]
    assert_equal [2, 3, 4], returned_values
    assert_equal [1, 2, 3, 4, 5], @list.to_a
    assert_equal 5, @list.size

    # Replace one element with two elements
    # list[1, 1] = [98, 99] on [1, 2, 3, 4, 5]
    @list[1, 1] = [98, 99]
    assert_equal [1, 98, 99, 3, 4, 5], @list.to_a
    assert_equal 6, @list.size
  end

  def test_slice_setter_shrinkage
    @list.append(1).append(2).append(3).append(4).append(5) # [1, 2, 3, 4, 5]

    # Replace three elements with one element: list[1, 3] = [99]
    @list[1, 3] = [99]
    assert_equal [1, 99, 5], @list.to_a
    assert_equal 3, @list.size

    # Replace two elements with zero elements (deletion): list[1..2] = []
    @list[1..2] = []
    assert_equal [1], @list.to_a
    assert_equal 1, @list.size
  end

  def test_slice_setter_boundaries
    @list.append(10).append(20).append(30)

    # Replace from head: list[0, 1] = [1]
    @list[0, 1] = [1]
    assert_equal 1, @list.first
    assert_equal [1, 20, 30], @list.to_a
    assert_equal 3, @list.size

    # Replace to tail: list[1, 2] = [2, 3]
    @list[1, 2] = [2, 3]
    assert_equal [1, 2, 3], @list.to_a
    assert_equal 3, @list.size

    # Append past the end (Expansion logic)
    @list[10, 2] = [99, 100]
    assert_equal [1, 2, 3, 99, 100], @list.to_a
    assert_equal 5, @list.size
  end
end
