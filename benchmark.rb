# frozen_string_literal: true

# benchmark.rb - Compare Struct vs Class performance
# Run with: ruby benchmark.rb
require 'benchmark'

# Struct version
NodeStruct = Struct.new(:value, :prev, :next)

# Class version
class NodeClass
  attr_accessor :value, :prev, :next

  def initialize(value, prev_node, next_node)
    @value = value
    @prev = prev_node
    @next = next_node
  end
end

N = 2_000_000

puts "Creating and accessing #{N} nodes:\n\n"

Benchmark.bm(20) do |x|
  x.report('Class creation:') do
    N.times { |i| NodeClass.new(i, nil, nil) }
  end

  x.report('Struct creation:') do
    N.times { |i| NodeStruct.new(i, nil, nil) }
  end

  # Test access speed (the important part!)
  struct_nodes = Array.new(1000) { |i| NodeStruct.new(i, nil, nil) }
  class_nodes = Array.new(1000) { |i| NodeClass.new(i, nil, nil) }

  x.report('Class access:') do
    N.times do
      node = class_nodes[rand(1000)]
      v = node.value
      node.value = v + 1
    end
  end
  x.report('Struct access:') do
    N.times do
      node = struct_nodes[rand(1000)]
      v = node.value
      node.value = v + 1
    end
  end
end

puts "\nConclusion: Run this benchmark on your target Ruby version to decide!"
