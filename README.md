# DLinked

A fast, lightweight doubly linked list implementation for Ruby.

## Features

- **Lightweight**: Minimal memory footprint using optimized node class
- **Fast**: O(1) operations for insertion/deletion at both ends
- **Ruby-native**: Includes `Enumerable` for full integration with Ruby
- **Bidirectional**: Iterate forward or backward efficiently
- **LRU-Ready**: Includes the specialized `DLinked::CacheList` subclass, which integrates a hash map for O(1) LRU cache management (access, insertion, eviction).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dlinked'
```

Or install it yourself:

```bash
gem install dlinked
```

## Test

```bash
bundle exec rake test
```

## Documentation

To generate the YARD documentation for this project, run:

```bash
bundle exec yard doc
```

This will create a `doc/` directory containing the full HTML documentation. You can view it by opening `doc/index.html` in your browser.

## Usage
### 1. Basic Initialization and O(1) Operations
Demonstrate creating the list, adding elements to both ends, and removing them quickly.


```ruby
require 'dlinked'

# 1. Initialization
list = DLinked::List.new
list.size # => 0

# 2. O(1) Prepend (Add to Head)
list.prepend(20).prepend(10) # Using method chaining
# The list now looks like: [10, 20]

# 3. O(1) Append (Add to Tail)
list << 30
list.append(40)
# The list now looks like: [10, 20, 30, 40]

# 4. O(1) Removal
list.shift # => 10 (Removes from head)
list.pop   # => 40 (Removes from tail)
# The list now looks like: [20, 30]

list.to_a # => [20, 30]
```
### 2. Array-Like Access and Assignment
Show users how the list behaves like a Ruby Array, utilizing the [] and []= methods you implemented.


```ruby
list = DLinked::List.new
list << 'A' << 'B' << 'C' << 'D'

# 1. Access by Index
list[2]   # => 'C'
list[-1]  # => 'D' (Accessing from the tail)

# 2. Element Assignment (O(n) but familiar)
list[1] = 'B_NEW'
list.to_a # => ["A", "B_NEW", "C", "D"]

# 3. Slice/Range Access
list[1, 2].to_a # => ["B_NEW", "C"] (start at 1, length 2)
list[0..2].to_a # => ["A", "B_NEW", "C"] (using a Range)

# 4. Slice Replacement (Deletion and Insertion)
list[1, 2] = ['X', 'Y', 'Z'] # Replace two elements with three new elements
list.to_a # => ["A", "X", "Y", "Z", "D"]
list.size # => 5
```
### 3. Enumerable and Iteration
Demonstrate how it works seamlessly with standard Ruby collection methods.


```ruby
list = DLinked::List.new
list << 10 << 20 << 30 << 40

# Standard Enumerable methods work out of the box
list.map { |n| n * 2 }     # => [20, 40, 60, 80]
list.select(&:even?)        # => [10, 20, 30, 40]

# O(n) Insertion in the middle
list.insert(2, 25)
list.to_a                  # => [10, 20, 25, 30, 40]

# O(n) Deletion by value
list.delete(20)
list.to_a                  # => [10, 25, 30, 40]
```


### 4. Utility, Inspection, and Conversion Methods
This section covers the basic checks, conversions, and advanced destructive operations.

```ruby

list = DLinked::List.new
list << 10 << 20 << 30

# --- Basic Inspection ---

list.size     # => 3
list.length   # => 3 (alias for size)
list.empty?   # => false
DLinked::List.new.empty? # => true

list.first    # => 10 (O(1))
list.last     # => 30 (O(1))

list.to_a     # => [10, 20, 30]
list.to_s     # => "[10, 20, 30]"
list.inspect  # => "[10, 20, 30]"

# --- Lookup ---

list.index(20) # => 1
list.index(99) # => nil (Value not found)
```

### 5. Advanced Insertion, Deletion, and Slicing
Demonstrate non-O(1) operations that are useful for list manipulation, including the destructive slice! method.

```ruby


list = DLinked::List.new
list << 'A' << 'B' << 'C' << 'D' << 'E'

# --- O(n) Insertion ---

# Insert at the middle (index 2)
list.insert(2, 'Z')
list.to_a # => ["A", "B", "Z", "C", "D", "E"]
list.insert(0, 'Start') # Same as prepend (O(1))
list.to_a # => ["Start", "A", "B", "Z", "C", "D", "E"]

# --- Deletion by Value ---

list.delete('Z') # => "Z" (Returns the deleted value)
list.to_a        # => ["Start", "A", "B", "C", "D", "E"]

# --- Destructive Slicing (slice!) ---

# Extract and remove a slice of 2 elements, starting at index 1
removed_slice = list.slice!(1, 2)
list.to_a        # => ["Start", "C", "D", "E"]
removed_slice.to_a # => ["A", "B"]

# Remove one element using a range (index 2)
list.slice!(2..2)
list.to_a        # => ["Start", "C", "E"]

list.size        # => 3
```

### 6. Concatenation and Arithmetic
Demonstrate how lists can be combined.

```ruby


list1 = DLinked::List.new << 1 << 2
list2 = DLinked::List.new << 3 << 4

# Non-destructive concatenation (returns a new list)
new_list = list1 + list2
new_list.to_a # => [1, 2, 3, 4]
list1.to_a    # => [1, 2] (list1 is unchanged)

# Destructive concatenation (modifies list1)
list1.concat(list2)
list1.to_a # => [1, 2, 3, 4]
```


### 7. DLinked::CacheList (LRU Cache Utility)
`DLinked::CacheList` is a specialized subclass of `DLinked::List` designed to be the backbone of a **Least Recently Used (LRU) cache**. It combines a doubly linked list with a hash map to provide **O(1)**time complexity for all critical LRU cache operations. All core key management methods have **O(1)** complexity:
- #prepend_key(key, value) (Add as MRU)
- #move_to_head_by_key(key) (Touch/Access)
- #pop_key (Evict LRU)
- #remove_by_key(key) (Remove)

- **Most Recently Used (MRU)** items are at the **head** of the list.
- **Least Recently Used (LRU)** items are at the **tail** of the list.

This makes it highly efficient for tracking key access order in a memory-limited cache.

```ruby
require 'dlinked'

# 1. Initialization
lru_list = DLinked::CacheList.new
lru_list.size # => 0

# 2. Add keys to the cache (as MRU)
# In a real cache, the value might be the cached data itself.
# For key tracking, value can be the same as the key.
lru_list.prepend_key(:key1, :key1)
lru_list.prepend_key(:key2, :key2)
lru_list.prepend_key(:key3, :key3)

# List order (MRU to LRU): [:key3, :key2, :key1]
lru_list.to_a # => [:key3, :key2, :key1]

# 3. "Touch" an existing key, moving it to the head (MRU)
lru_list.move_to_head_by_key(:key1)

# List order is now: [:key1, :key3, :key2]
lru_list.to_a # => [:key1, :key3, :key2]

# 4. Evict the least recently used key (from the tail)
evicted_key = lru_list.pop_key
evicted_key # => :key2

# List order is now: [:key1, :key3]
lru_list.to_a # => [:key1, :key3]

# 5. Remove a specific key (O(1) operation)
lru_list.remove_by_key(:key3)
lru_list.to_a # => [:key1]

# 6. Clear the list and the key map (O(1) operation)
lru_list.clear
lru_list.size # => 0

```

### Real-World Example: A Complete LRU Cache
While `DLinked::CacheList` provides the low-level, high-performance key tracking, you can easily build a complete, practical `LRUCache` class around it.

The following example demonstrates how to combine `DLinked::CacheList` with a `Hash` for data storage to create a fully functional LRU cache.

```ruby
# A complete, working implementation of a Least Recently Used (LRU) Cache
# built on top of DLinked::CacheList.
class LRUCache
  attr_reader :capacity, :size

  def initialize(capacity)
    raise ArgumentError, 'Capacity must be a positive integer' unless capacity.is_a?(Integer) && capacity > 0

    @capacity = capacity
    @size = 0
    @list = DLinked::CacheList.new
    @data = {}
  end

  def get(key)
    return nil unless @data.key?(key)
    @list.move_to_head_by_key(key)
    @data[key]
  end

  def set(key, value)
    if @data.key?(key)
      @list.move_to_head_by_key(key)
    else
      @list.prepend_key(key, value)
      @size += 1
      evict if @size > @capacity
    end
    @data[key] = value
  end

  private

  def evict
    lru_key = @list.pop_key
    return unless lru_key
    @data.delete(lru_key)
    @size -= 1
  end
end
```

For a complete, runnable demonstration of this `LRUCache` class in action, see the [lru_cache_example.rb](./lru_cache_example.rb) file.

## ⚡ Performance Characteristics
This library is designed to offer the guaranteed performance benefits of a Doubly Linked List over a standard Ruby `Array` for certain operations.

 | Operation | Method(s) | Complexity | Notes | 
  | - | - | - | - | 
  | End Insertion | append, prepend, push, unshift, << | $O(1)$ | Constant time, regardless of list size. | 
  | End Deletion | pop, shift | $O(1)$ | Constant time. | 
  | End Access | first, last | $O(1)$ | Constant time access to boundary values. | 
  | Middle Insertion/Deletion | insert, delete (by value), slice!, []= (slice) | $O(n)$ | Requires traversal to find the node. | 
  | Random Access/Search | [] (getter), index | $O(n)$ | Requires traversal; average time is $O(n/2)$. | 



## ⚡ Performance Benchmarks

To quantify the performance benefits of `DLinked::List` over Ruby's `Array`, a benchmark suite is available in `benchmark.rb`. It uses the `benchmark-ips` gem to compare the performance of single operations on a pre-filled data structure of 10,000 items.

The benchmark measures a single operation (e.g., `shift`) and immediately performs the inverse operation (e.g., `push`) to ensure the list size remains constant for every measurement. This provides a more accurate comparison of how each data structure handles these calls on a large collection.

You can run the benchmark yourself:

```bash
bundle install
bundle exec ruby benchmark.rb
```

**Results:**

The results below were generated on Ruby 3.1.4. They demonstrate that for a list of 10,000 items, the performance of Ruby's native, C-implemented `Array` is significantly faster than `DLinked::List`'s pure Ruby implementation, even for operations where the linked list has a better theoretical time complexity.

| Operation | Comparison | Analysis |
| :--- | :--- | :--- |
| `append` / `push` | `Array` is ~5.2x faster | `Array` is faster. This is expected as it's a highly optimized C implementation, while `DLinked::List` has the overhead of Ruby method calls and `Node` object allocation. |
| `prepend` / `unshift`| `Array` is ~5.1x faster | Surprisingly, `Array#unshift` is still faster at this scale. The cost of memory shifting in C for 10,000 items is lower than the overhead of `DLinked::List`'s Ruby implementation. |
| `pop` | `Array` is ~5.3x faster | Similar to `push`, the native `Array` implementation is faster for this O(1) operation. |
| `shift` | `Array` is ~5.4x faster | Like `unshift`, `Array#shift`'s O(n) operation in C is faster than `DLinked::List`'s O(1) operation in Ruby at this list size, due to the overhead of the Ruby implementation. |

**Conclusion:**

These benchmarks show that the raw speed of the underlying C implementation of `Array` outweighs the Big-O algorithmic advantages of a pure Ruby linked list for collections of this size. `DLinked::List` is better suited for educational purposes or for algorithms where the explicit node structure and pointer manipulation are more important than raw wall-clock performance against `Array`.

## 💾 Memory Usage

While memory usage is highly dependent on the objects stored, the overhead of the list structure itself is minimal and highly efficient:

*   **Node Overhead:** Each node in the list uses approximately 40 bytes. This includes the object header, and three necessary pointers:
    
    1.  Pointer to the stored **value**
        
    2.  Pointer to the **next** node
        
    3.  Pointer to the **previous** node
        
*   **Efficiency Advantage:** This structured overhead is often more memory-efficient than a large Ruby `Array` that requires constant reallocation and copying when its capacity is exceeded, especially if the `Array` is being modified frequently at the head.

## License

MIT License. See LICENSE.txt for details.