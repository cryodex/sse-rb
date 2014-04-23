=begin
require 'bloom-filter'

class String
  def |( other )
    b1 = self.unpack("c*")
    b2 = other.unpack("c*")
    b1.zip(b2).map{ |a,b| a | b }.pack("c*")
  end
end

filter_a = BloomFilter.new(size: 100)
filter_a.insert("foo")

filter_b = BloomFilter.new(size: 100)
filter_b.insert("bar")

filter_c = BloomFilter.new(size: 100)
filter_c.binary = filter_a.binary | filter_b.binary

puts filter_c.include?("foo")

puts filter_c.include?("aaaa")
=end

class Index

  require 'btree'
  
  def initialize
    @tree = Btree.create(2)
    
    @tree['foo'] = 'foo value'
    @tree['bar'] = 'bar value'
    @tree['bar2'] = 'bar2 value'
    @tree['bar3'] = 'bar3 value'
  end
  
  def insert(bf)
    _insert(bf, @tree.root)
  end
  
  def _insert(bf, node)
    
    # if node is not leaf, direct the search
    # for the new filter place
    if !node.leaf
      node.val ||= bf
      closest_value, closest_index = -1, -1
      node.children.each_with_index do |child, index|
        if distance(child.val, index) < closest_value
          closest_index = index
        end
      end
      new_sibling = node.children[closest_index].insert(bf)
      return if !new_sibling
      if node.parent == nil
        new_root = Btree::Node.new
        new_root.val = node.val || new_sibling.val
        new_root.parent = nil
        new_root.children.add(node)
        new_root.children.add(new_sibling)
        root = new_root
        node.parent = new_root
        sibling.parent = new_root
        return
      else
        return new_sibling
      end
    else
      new_leaf = Btree::Node.new
      new_leaf.val = bf
      new_sibling = node.insert(new_leaf)
      return new_sibling
    end
    
  end
  
  def find_matches(node, o)
    
    return if !match(node.value, o) == o
     
    return node.if node.lead
    
  end
  
end

index = Index.new
index.insert('test')
