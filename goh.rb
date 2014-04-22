module SSE
  
  class Client
  
    require 'openssl'
    
    def initialize(server, master_key)
      @server = server
      @cipher = Cipher.new(master_key)
    end
    
    def setup(texts)
      
      params = bloom_parameters
      
      indexes = texts.each_with_index.map do |text, id|
        document = Document.new(text, id)
        index = Index.new(document, @cipher, params)
      end
      
       @server.setup(indexes)
              
    end
  
    def update(operation, index)
    
      @server.update(operation, index)
      
      
    end
  
    def search(word)
      
      trapdoor = @cipher.compute_trapdoor(word)
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
      @text.split(' ')
    end
    
  end
  
  class Index
    
    require 'bloom-filter'
    
    def initialize(document, cipher, params)
      
      @document = document
      @cipher = cipher
      
      @index = create_index(params)
      
      build_index!
      
    end
    
    def search(code_word)
      
      @index.include?(code_word)
      
    end
    
    private
    
    def create_cipher(key)
      
      Cipher.new(key)
      
    end
    
    def create_index(params)
      
      BloomFilter.new(params)
      
    end
    
    def build_index!
      
      words = @document.tokenize
      doc_id = @document.id.to_s
      
      # Step 1: compute trapdoor, codeword and insert in BF.
      words.each_with_index do |word|
        trap_door = @cipher.compute_trapdoor(word)
        puts "trap door for #{word}: " + trap_door
        code_word = @cipher.compute_code_word(doc_id, trap_door)
        puts "code word for #{doc_id}, #{word}: " + code_word
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

  class Cipher
    
    def initialize(k_priv = nil, size = 256)
      
      @master_key = k_priv
      puts @master_key.inspect
      
      size = k_priv ? @master_key.bytesize * 8 : size
      @digest =  OpenSSL::Digest.new("sha#{@size}")
      
    end
    
    def create_prf(prf_key)
      OpenSSL::HMAC.new(prf_key, @digest)
    end
    
    def compute_trapdoor(word)
      create_prf(@master_key).update(word).to_s
    end
    
    def compute_code_word(doc_id, trap_door)
      create_prf(trap_door).update(doc_id.to_s).to_s
    end
    
  end
  
  class Server
  
    def setup(indexes)
      @indexes = indexes
    end
  
    def update(operation)
      
      if operation == :post
        
      elsif operation == :put
        
      elsif operation == :delete
        
      else
        raise 'Unsupported operation'
      end
    
    end
  
    def search(trapdoor)
      
      results = []
      cipher = Cipher.new
      
      @indexes.each_with_index do |index, id|
        code_word = cipher.compute_code_word(id, trapdoor)
        puts "Code word for doc id #{id}: #{code_word}"
        results.push(id) if index.search(code_word)
      end
      
      results
      
    end
  
  end
  
end


server = SSE::Server.new

master_key = OpenSSL::Digest::SHA256.hexdigest('')
client = SSE::Client.new(server, master_key)

texts = ['hello world hey!', 'howdy hello howda yadelidoo!', 'xxx']
client.setup(texts)

puts client.search('hello').size