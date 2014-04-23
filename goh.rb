class String
  def |( other )
    b1 = self.unpack("c*")
    b2 = other.unpack("c*")
    b1.zip(b2).map{ |a,b| a | b }.pack("c*")
  end
  def ^( other )
    b1 = self.unpack("c*")
    b2 = other.unpack("c*")
    b1.zip(b2).map{ |a,b| a ^ b }.pack("c*")
  end
end

module SSE
  
  class Client
  
    require 'openssl'
    require 'cmac'
    
    def initialize(server, master_key)
      @server = server
      @cipher = CMAC::Digest.new(master_key)
    end
    
    def setup(texts)
      
      params = bloom_parameters
      
      indexes = texts.each_with_index.map do |text, id|
        document = Document.new(text, id.to_s)
        index = Index.new(document, @cipher, params)
      end
      
       @server.setup(indexes)
              
    end
  
    def update(operation, index)
    
      @server.update(operation, index)
      
    end
  
    def search(word)
      
      trapdoor = @cipher.update(word)
      @server.search(trapdoor)
      
    end
    
    private
    
    def keygen(size)
      
      random_bytes(size / 8)
      
    end
    
    
    def bloom_parameters
      { size: 100_000, error_rate: 0.01 }
    end
    
    def random_bytes(num_bytes)
      OpenSSL::Random.random_bytes(num_bytes)
    end
  
  end
  
  class Document
    
    attr_accessor :text, :id
    
    def initialize(text, id)
      @text, @id = text, id
    end
    
    def tokenize
      @text.downcase.gsub(/[^0-9a-z ]/i, '').split(' ').uniq
    end
    
  end
  
  class Index
    
    attr_accessor :index, :id
    
    require 'bloom-filter'
    
    def initialize(document, cipher, params)
      
      @document = document
      @id = document.id
      @cipher = cipher
      
      @index = create_index(params)
      
      build_index!
      
    end
    
    def search(code_word)
      
      @index.include?(code_word)
      
    end
    
    private
    
    def create_index(params)
      
      BloomFilter.new(params)
      
    end
    
    def build_index!
      
      words = @document.tokenize
      doc_id = @document.id
      
      # Step 1: compute trapdoor, codeword and insert in BF.
      words.each_with_index do |word|
        trap_door = @cipher.update(word)
        cipher = CMAC::Digest.new(trap_door)
        code_word = cipher.update(doc_id)
        @index.insert(code_word)
      end
      
      # Step 2: compute upper bound u on number of tokens
      u = @document.text.bytesize
      
      # Step 3 
      # v = words.uniq.size
      # num_ones = (u - v) * r
      # insert ones
      
    end
    
  end

  class Server
    
    def setup(indexes)
      
      @indexes = indexes
      
      @tree = []
     #  index_binary(@indexes.map(&:index))
      
    end
    
    def update(operation)
      
      if operation == :post
        
      elsif operation == :put
        
      elsif operation == :delete
        
      else
        raise 'Unsupported operation'
      end
    
    end
    
    def search(trap_door)
      
      results = []
      
      # i = @indexes.size - 1
      
      cipher = CMAC::Digest.new(trap_door)
      code_words = []
      
      @indexes.each_with_index do |index, i|
        
        code_word = cipher.update(index.id)
        
        code_words << code_word
        
        if index.index.include?(code_word)
          results << i
        end
        
      end
      
     #  search_binary(code_words)
      
      results
      
    end
    
    # Binary tree
    def index_binary(indexes)
      
      if indexes.size <= 2
        @tree << indexes
        return
      end
      
      results = []
      
      n = 8
      
      indexes.each_slice(n) do |tuple|
        
        next if tuple.any?(&:nil?)
        
        print '*'
        
        filter = BloomFilter.new({ size: 100_000, error_rate: 0.01 })
        
        binary = tuple.first.binary
        
        tuple.each_with_index do |value, index|
          
          if index == 0
            binary = value.binary
          else
            binary = binary | value.binary
          end
        end
        
        filter.binary = binary
        
        results << filter
        
      end
      
      if indexes.size % n != 0
        results << indexes[-1]
      end
      
      @tree << results
      
      index_binary(results)
      
    end

    def search_binary(code_words)
      
      results = []
      
      i = @tree.size - 1

      while i >= 0

        filters = @tree[i]

        filters.each_with_index do |filter, j|
          code_words.each do |code_word|
            break if !filter.include?(code_word)
            results << [i, j]
          end
        end

        i -= 1

      end
      
      results
    
    end
    
  end
  
end

require 'benchmark'
require 'lorem_ipsum_amet'
require 'ruby-prof'

server = SSE::Server.new

master_key = OpenSSL::Digest::SHA256.hexdigest('').byteslice(0, 16)
client = SSE::Client.new(server, master_key)

texts = []

# Avg 60 ms/add
10000.times do
  text = LoremIpsum.lorem_ipsum(words: 1000)
  texts << text
end

puts "Done."

Benchmark.bm do |x|

  x.report do
    client.setup(texts)
  end
  
end

Benchmark.bm do |x|

  # Avg 25 ms/search (10 000 docs, 1000 words/doc, 100 000 bits/filter)
  # Avg 260 ms/search (100 000 docs, 1000 words/doc)
  x.report do
    # RubyProf.start
    i = 100
    while i > 0
      client.search('Lorem')
      i -= 1
    end
    # result = RubyProf.stop
    # printer = RubyProf::FlatPrinter.new(result)
    # printer.print(STDOUT)
  end
  
end