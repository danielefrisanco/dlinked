

require 'dlinked'  # Add this line!

list = DLinked::List.new
list.append(2).append(3).prepend(1)
puts "After operations: #{list}"
puts "Size: #{list.size}"

# More examples...
list << 10 << 20 << 30
puts "List: #{list}"
puts "First: #{list.first}, Last: #{list.last}"

list.each { |v| puts "  Value: #{v}" }
if __FILE__ == $0
  list = DLinked::List.new
  
  # Test append and prepend
  list.append(2).append(3).prepend(1)
  puts "After operations: #{list}"  # [1, 2, 3]
  puts "Size: #{list.size}"          # 3
  
  # Test pop and shift
  puts "Pop: #{list.pop}"            # 3
  puts "Shift: #{list.shift}"        # 1
  puts "After pop/shift: #{list}"    # [2]
  
  # Test iteration
  list.append(4).append(6).prepend(0)
  puts "\nForward iteration:"
  list.each { |v| puts "  #{v}" }
  
  puts "\nReverse iteration:"
  list.reverse_each { |v| puts "  #{v}" }
  
  # Test enumerable methods
  puts "\nSquared values: #{list.map { |v| v * v }}"
  puts "Sum: #{list.sum}"
  
  # Test delete
  list.delete(2)
  puts "After deleting 2: #{list}"
end