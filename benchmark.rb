# frozen_string_literal: true

require 'benchmark/ips'
require 'dlinked'

puts "Ruby version: #{RUBY_VERSION}"
puts "DLinked version: #{DLinked::VERSION}"

LIST_SIZE = 10_000
puts "\n--- Benchmarking single operations on a list of #{LIST_SIZE} items ---"
puts "A single operation is performed, and then undone to maintain list size."

# --- Setup ---
array = (0...LIST_SIZE).to_a
list = DLinked::List.new
array.each { |i| list.append(i) }

# --- Benchmark Suite ---

puts "\nAppend/Push at the end:"
Benchmark.ips do |x|
  x.report("Array#push") do
    array.push(0)
    array.pop
  end

  x.report("DLinked::List#append") do
    list.append(0)
    list.pop
  end

  x.compare!
end

puts "\nPrepend/Unshift at the beginning:"
Benchmark.ips do |x|
  x.report("Array#unshift") do
    array.unshift(0)
    array.shift
  end

  x.report("DLinked::List#prepend") do
    list.prepend(0)
    list.shift
  end

  x.compare! 
end

puts "\nPop from the end:"
Benchmark.ips do |x|
  x.report("Array#pop") do
    el = array.pop
    array.push(el)
  end

  x.report("DLinked::List#pop") do
    el = list.pop
    list.append(el)
  end

  x.compare!
end

puts "\nShift from the beginning:"
Benchmark.ips do |x|
  x.report("Array#shift") do
    el = array.shift
    array.push(el)
  end

  x.report("DLinked::List#shift") do
    el = list.shift
    list.append(el)
  end

  x.compare!
end
