# DLinked

A fast, lightweight doubly linked list implementation for Ruby.

## Features

- **Lightweight**: Minimal memory footprint using optimized node class
- **Fast**: O(1) operations for insertion/deletion at both ends
- **Ruby-native**: Includes Enumerable for full integration with Ruby
- **Bidirectional**: Iterate forward or backward efficiently


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
bundle exec ruby test/test_d_linked_list.rb

```

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

## ⚡ Performance Characteristics
This library is designed to offer the guaranteed performance benefits of a Doubly Linked List over a standard Ruby `Array` for certain operations.

 | Operation | Method(s) | Complexity | Notes | 
  | - | - | - | - | 
  | End Insertion | append, prepend, push, unshift, << | $O(1)$ | Constant time, regardless of list size. | 
  | End Deletion | pop, shift | $O(1)$ | Constant time. | 
  | End Access | first, last | $O(1)$ | Constant time access to boundary values. | 
  | Middle Insertion/Deletion | insert, delete (by value), slice!, []= (slice) | $O(n)$ | Requires traversal to find the node. | 
  | Random Access/Search | [] (getter), index | $O(n)$ | Requires traversal; average time is $O(n/2)$. | 



## 💾 Memory Usage

While memory usage is highly dependent on the objects stored, the overhead of the list structure itself is minimal and highly efficient:

*   **Node Overhead:** Each node in the list uses approximately 40 bytes. This includes the object header, and three necessary pointers:
    
    1.  Pointer to the stored **value**
        
    2.  Pointer to the **next** node
        
    3.  Pointer to the **previous** node
        
*   **Efficiency Advantage:** This structured overhead is often more memory-efficient than a large Ruby `Array` that requires constant reallocation and copying when its capacity is exceeded, especially if the `Array` is being modified frequently at the head.

## License

MIT License. See LICENSE.txt for details.