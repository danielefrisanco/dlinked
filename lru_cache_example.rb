# frozen_string_literal: true

require 'dlinked'

# A complete, working implementation of a Least Recently Used (LRU) Cache
# built on top of DLinked::CacheList.
#
# An LRU Cache is a high-performance cache that evicts the least recently
# used item when it reaches its capacity. This example demonstrates how
# DLinked::CacheList's O(1) operations make it a perfect foundation for
# this data structure.
class LRUCache
  # @!attribute [r] capacity
  #   @return [Integer] The maximum number of items the cache can hold.
  # @!attribute [r] size
  #   @return [Integer] The current number of items in the cache.
  attr_reader :capacity, :size

  # Initializes a new LRU cache.
  #
  # @param capacity [Integer] The maximum number of items the cache can store.
  #   Must be a positive integer.
  def initialize(capacity)
    raise ArgumentError, 'Capacity must be a positive integer' unless capacity.is_a?(Integer) && capacity > 0

    @capacity = capacity
    @size = 0
    @list = DLinked::CacheList.new
    @data = {}
  end

  # Retrieves the value for a given key from the cache.
  #
  # If the key exists, it is marked as "most recently used" by being moved
  # to the head of the list. This is an O(1) operation.
  #
  # @param key [Object] The key to look up.
  # @return [Object, nil] The cached value, or `nil` if the key is not found.
  def get(key)
    return nil unless @data.key?(key)

    # "Touch" the item by moving it to the front of the list, marking it as
    # the most recently used.
    @list.move_to_head_by_key(key)

    @data[key]
  end

  # Adds or updates a key-value pair in the cache.
  #
  # - If the key already exists, its value is updated.
  # - If the key is new, it is added to the cache.
  #
  # In both cases, the item is marked as "most recently used."
  #
  # If adding a new item causes the cache to exceed its capacity, the
  # least recently used (LRU) item is automatically evicted.
  # All operations here are O(1).
  #
  # @param key [Object] The key to set.
  # @param value [Object] The value to store.
  # @return [Object] The stored value.
  def set(key, value)
    if @data.key?(key)
      # Key exists, just update the value and mark it as most recently used.
      @list.move_to_head_by_key(key)
    else
      # Key is new. Add it to the front of the list.
      # We store the key in the list, and the value in the hash.
      @list.prepend_key(key, key)
      @size += 1

      # If we exceeded capacity, evict the least recently used item.
      evict if @size > @capacity
    end

    # Store the actual data in our hash.
    @data[key] = value
  end

  # Removes a key-value pair from the cache.
  # This is an O(1) operation.
  #
  # @param key [Object] The key to remove.
  # @return [Object, nil] The value of the removed item, or `nil` if the key was not found.
  def delete(key)
    return nil unless @data.key?(key)

    @list.remove_by_key(key)
    @size -= 1
    @data.delete(key)
  end

  # Provides a human-readable view of the cache's state, showing the
  # order of items from most to least recently used.
  #
  # @return [String]
  def to_s
    # Iterate over the keys in the list (from MRU to LRU) and look up their values.
    items = @list.map { |key| "#{key}:#{@data[key]}" }.join(', ')
    "LRUCache (capacity: #{@capacity}, size: #{@size}) [MRU] #{items} [LRU]"
  end

  private

  # Evicts the least recently used (LRU) item from the cache.
  # This is an O(1) operation.
  def evict
    # DLinked::CacheList automatically tracks the LRU item at the tail.
    lru_key = @list.pop_key
    return unless lru_key

    @data.delete(lru_key)
    @size -= 1
    puts "Evicted: #{lru_key}"
  end
end

# --- DEMONSTRATION ---
if __FILE__ == $PROGRAM_NAME
  puts "--- LRU Cache Demonstration (Capacity: 3) ---"
  cache = LRUCache.new(3)

  puts "\n1. Setting initial values: a=1, b=2, c=3"
  cache.set(:a, 1)
  cache.set(:b, 2)
  cache.set(:c, 3)
  puts cache # c should be MRU

  puts "\n2. Accessing key 'a'"
  cache.get(:a)
  puts cache # a should now be MRU

  puts "\n3. Adding a new item 'd=4' (should evict 'b')"
  cache.set(:d, 4)
  puts cache # d should be MRU, b should be gone

  puts "\n4. Checking contents"
  puts "cache.get(:a) -> #{cache.get(:a)}"
  puts "cache.get(:b) -> #{cache.get(:b) || 'nil (evicted)'}"
  puts "cache.get(:c) -> #{cache.get(:c)}"
  puts "cache.get(:d) -> #{cache.get(:d)}"

  puts "\n5. Deleting key 'c'"
  cache.delete(:c)
  puts cache

  puts "\n6. Clearing the cache"
  cache.set(:e, 5)
  cache.set(:f, 6)
  puts cache
end
