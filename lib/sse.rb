require 'sse/wrapper'
require 'sse/version'

module SSE
  
  class Cipher
    
    require 'openssl'
    
    CIPHER_SIZE = 16
    M = 4
    SALT_LEN = 8
    R = CIPHER_SIZE - M
    
    def search_words(token, ciphs)
      
      result = []
      
      ciphs.each_with_index do |ciph, index|
        result << index if search_word(token, ciph)
      end
      
      result
      
    end
    
    def search_exists(token, ciphs)
      
     ciphs.any? do |ciph|
        search_word(token, ciph)
      end
      
    end
    
    def search_word(token, ciph)
      
      ciph2 = xor(ciph, token[:ct])
      salt = ciph2.byteslice(0, R)
      funcpart = ciph2.byteslice(R, ciph2.bytesize - R)
      
      func = prp(token[:key], salt)
      
      func = func.byteslice(R, M)
      
      func == funcpart
      
    end
    
    def generate_token(key, word)
      
      ciph, word_key = half_encrypt_word(key, word)
      
      { ct: ciph, key: word_key }
      
    end
    
    def encrypt_words(key, words)
      
      result = []
      
      words.each_with_index do |word, index|
        result << encrypt_word(key, word, index)
      end
      
      result
      
    end
    
    def encrypt_word(key, word, index)
      
      if word.size > CIPHER_SIZE
        raise 'Word is too long'
      end
      
      ciph, word_key = half_encrypt_word(key, word)
      
      salt = prp(key, [index].pack('L'))
      
      salt = salt.byteslice(salt.size - R, R)
      
      func = prp(word_key, salt)
      func = func.byteslice(R, M)
      xor(ciph, (salt + func))
      
    end
    
    def half_encrypt_word(key, word)
      
      ciph = encrypt_sym(key, word)
      
      l_i = ciph.byteslice(0, R)
      
      word_key = prp(key, l_i)
      
      return ciph, word_key
      
    end
    
    def prp(key, val)
      
      encrypt_sym(key, val)
      
    end
    
    def encrypt_sym(key, word)
      
      cipher = SIV::Cipher.new(key)
      cipher.encrypt(word)
      
    end
    
    def decrypt_words(key, words)
      
      result = []
      
      words.each_with_index do |word, index|
        result << decrypt_word(key, word, index)
      end
      
      result
      
    end
    
    def decrypt_word(key, word, index)
      
      salt = prp(key, [index].pack('L'))
      salt = salt.byteslice(salt.bytesize - R, R)
      
      l_i = xor(salt, word.byteslice(0, R))
      
      word_key = prp(key, l_i)
      
      func = prp(word_key, salt).byteslice(R, M)
      
      r_i = xor(func, word.byteslice(R, M))
      
      decrypt_sym(key, l_i + r_i)
      
    end
    
    def decrypt_sym(key, word)
      
      cipher = SIV::Cipher.new(key)
      cipher.decrypt(word)
      
    end
    
    def xor(a, b)
      
      a_bytes = a.unpack("C*")
      b_bytes = b.unpack("C*")
      
      xor_bytes = a_bytes.zip(b_bytes)
      .map { |pair| pair[0] ^ pair[1] }
      
      xor_bytes.pack("C*")
      
    end
    
  end
  
end