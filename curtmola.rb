module SSE
  
  module Crypto
  
    def prp(key, data)
      digest = OpenSSL::Digest::SHA256.new
      OpenSSL::HMAC::Digest.digest(digest, key, data)
    end
  
    def pi(key, data)
      cipher = SIV::Cipher.new(key)
      cipher.encrypt(data)
    end
  
    def psi
      cipher = SIV::Cipher.new(key)
      cipher.encrypt(data)
    end
    
    def random_bits(num_bits)
      OpenSSL::Random.random_bytes(num_bits / 8)
    end
    
  end
  
  module Client
  
    include Crypto
    
    def initialize(collection)
      
      generate_keys!
      
      @collection = collection
      
      @word_index = {}
      build_word_index!
      
      @ctr = 1
      @A = {}
      @T = {}
      
      build_A!
      build_T!
      build_c!
      
    end
    
    private
    
    def generate_keys!
      k1 = random_bits(256)
      k2 = random_bits(256)
      k3 = random_bits(256)
      k4 = random_bits(128)
      @K = [0, k1, k2, k3, k4]
    end
    
    def build_word_index!
      
      @collection.each do |document|
        document.words.each do |word|
          @word_index[word] ||= []
          @word_index[word] << document.id
        end
      end
      
    end
    
    def build_A!
      
      i = 0
      
      @word_index.each do |word, set|
        
        k_ij_m1 = random_bits(256)
        k_ij, n_ij = nil, nil
        
        set.each_with_index do |id, j|
          
          k_ij = random_bits(256)
          n_ij = id + k_ij + psi(k1, @ctr + 1) 
          @A[psi(@K[1], @ctr)] = ske1(k_ij_m1, n_ij)
          @ctr += 1
          
        end
        
        @A[psi(@K[1], @ctr)] = ske1(k_ij, n_ij)
        
        # randomize
        
        i += 1
        
      end
      
    end
    
    def build_T!
      
      @word_index.each do |w_i, set|
        
        @T[pi(k3, w_i)] = (addr_A(n_i1) + ) ^ prf(@K[2], w_i)
        
        # randomize
        
      end
      
    end
    
    def build_c!
      
      @collection.each do |d_i|
        @c[d_i.id] = ske2(k4, d_i)
      end
      
    end
    
    
  end
  
  
  class Document
    
    attr_accessor :id, :words
    
    def initialize(text, id)
      @text, @id = text, id
      @words = tokenize(text)
    end
    
    private
    
    def tokenize(text)
      text.downcase.gsub(/[^0-9a-z ]/i, '').split(' ').uniq
    end
    
  end
  
end