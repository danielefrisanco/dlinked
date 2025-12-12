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

## Usage

```ruby
require 'dlinked'

list = DLinked::List.new

# Add elements
list.append(1)       # Add to end
list.prepend(0)      # Add to beginning
list << 2            # Alias for append
list.push(3)         # Another alias

# Remove elements
list.pop             # Remove from end
list.shift           # Remove from beginning

# Access elements
list.first           # Get first element
list.last            # Get last element
list[0]              # Access by index

# Iterate
list.each { |item| puts item }
list.reverse_each { |item| puts item }

# Use Enumerable methods
list.map { |x| x * 2 }
list.select { |x| x > 5 }
list.sum

# Other operations
list.size            # Number of elements
list.empty?          # Check if empty
list.delete(value)   # Delete first occurrence
list.clear           # Remove all elements
```

## Performance

All insertion and deletion operations at the ends are O(1):
- `append`, `prepend`, `push`, `unshift`: O(1)
- `pop`, `shift`: O(1)
- `first`, `last`: O(1)

Index-based access and search are O(n):
- `[]`, `index`, `delete`: O(n)

## Memory Usage

Each node uses approximately 40 bytes (object header + 3 pointers), making it one of the most memory-efficient implementations possible in Ruby.

## License

MIT License. See LICENSE.txt for details.