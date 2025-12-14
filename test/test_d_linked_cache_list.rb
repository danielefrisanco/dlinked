# frozen_string_literal: true
# --- START SIMPLECOV SETUP ---
require 'simplecov'
SimpleCov.start do
  # Add the new group for the specialized class
  add_group 'Core List', 'lib/d_linked/list.rb'
  add_group 'Cache List', 'lib/d_linked/cache_list.rb'
  add_group 'Nodes', 'lib/d_linked/list/node.rb'
  # Exclude test files themselves from the coverage report
  add_filter '/test/'
end
# --- END SIMPLECOV SETUP ---
require 'minitest/autorun'
require_relative '../lib/dlinked'

class TestDLinkedCacheList < Minitest::Test
  def setup
    # Initialize the CacheList (which initializes the internal @lru_nodes map)
    @list = DLinked::CacheList.new
  end

  ## --- Test Fixture Helpers ---
  
  # Helper to easily populate the list and get a reference to the key
  def populate_three_keys
    # Inserts keys (1, 2, 3) with values ('A', 'B', 'C'). List is currently [3, 2, 1] (Head to Tail)
    @list.prepend_key(1, 'A')
    @list.prepend_key(2, 'B')
    @list.prepend_key(3, 'C')
  end
  
  # Helper to convert the list to an array of *keys* for easy assertion
  def list_to_key_array
    # Use the base class's #each method, but access the node's key property
    # NOTE: This requires DLinked::List#each to yield the *node* itself OR we override #each
    # Assuming #each yields the node's VALUE, we must use an internal helper (for testing):
    
    current = @list.instance_variable_get(:@head)
    keys = []
    while current
      keys << current.key
      current = current.next
    end
    keys
  end

  # --- 1. Core LRU Operations ---

  def test_prepend_key_updates_list_and_map
    @list.prepend_key('K1', 10)
    
    assert_equal 1, @list.size
    assert @list.instance_variable_get(:@lru_nodes).key?('K1')
    
    # Check that the head node contains the correct key and value
    head_node = @list.instance_variable_get(:@head)
    assert_equal 'K1', head_node.key
    assert_equal 10, head_node.value
  end

  def test_clear_resets_list_and_map
    populate_three_keys
    
    @list.clear
    
    assert_equal 0, @list.size
    assert_equal 0, @list.instance_variable_get(:@lru_nodes).size
    assert_nil @list.instance_variable_get(:@head)
  end
  
  def test_pop_key_evicts_lru_item
    populate_three_keys # [3, 2, 1] (Head to Tail)
    
    # The least recently used key is '1' (at the tail)
    lru_key = @list.pop_key
    
    assert_equal 1, lru_key
    assert_equal 2, @list.size
    assert_equal [3, 2], list_to_key_array # List should be [3, 2]
    refute @list.instance_variable_get(:@lru_nodes).key?(1), "Key 1 should be removed from the map."
  end

  # --- 2. Touch/Move Operations ---

  def test_move_to_head_by_key_from_middle
    populate_three_keys # Initial: [3, 2, 1]
    
    # Move key 2 (middle) to the head (MRU)
    result = @list.move_to_head_by_key(2)
    
    assert result, "Move operation should succeed."
    assert_equal [2, 3, 1], list_to_key_array # Expected order: [2, 3, 1]
    assert_equal 3, @list.size
  end
  
  def test_move_to_head_by_key_from_tail
    populate_three_keys # Initial: [3, 2, 1]
    
    # Move key 1 (tail/LRU) to the head (MRU)
    result = @list.move_to_head_by_key(1)
    
    assert result, "Move operation should succeed."
    assert_equal [1, 3, 2], list_to_key_array # Expected order: [1, 3, 2]
  end

  def test_move_to_head_by_key_no_op
    populate_three_keys # Initial: [3, 2, 1]
    
    # Move key 3 (head/MRU) to the head (should be a no-op)
    result = @list.move_to_head_by_key(3)
    
    assert result, "Move operation should technically succeed (return true)."
    assert_equal [3, 2, 1], list_to_key_array # Order should not change
  end
  
  # --- 3. Removal Operations ---
  
  def test_remove_by_key_from_middle
    populate_three_keys # Initial: [3, 2, 1]
    
    # Remove key 2 (middle)
    result = @list.remove_by_key(2)
    
    assert result, "Remove operation should succeed."
    assert_equal [3, 1], list_to_key_array # Expected order: [3, 1]
    assert_equal 2, @list.size
    refute @list.instance_variable_get(:@lru_nodes).key?(2), "Key 2 should be removed from the map."
  end
  
  def test_remove_by_key_non_existent
    populate_three_keys
    
    result = @list.remove_by_key(99) # Non-existent key
    
    refute result, "Remove operation should fail (return false)."
    assert_equal 3, @list.size
    assert_equal [3, 2, 1], list_to_key_array # List should be unchanged
  end

  # --- 4. Inherited List Behavior (Quick Check) ---
  
  def test_inherited_append_works_but_is_not_lru_managed
    # We must call the base list's public append.
    # Note: Your implementation of CacheList does *not* override the public append,
    # so calling it should use the inherited DLinked::List#append.
    @list.append('ValueA') 
    
    assert_equal 1, @list.size
    assert_equal 'ValueA', @list.first # Inherited List#first returns value
    
    # Crucially, the map should NOT be updated by the base method
    assert_equal 0, @list.instance_variable_get(:@lru_nodes).size
  end
end