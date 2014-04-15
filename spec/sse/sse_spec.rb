require 'spec_helper'
require 'sse'

describe SSE do

  it "should provide basic functionality" do
    
    cipher = SSE::Cipher.new('dfsfsdfadsdfs')
    
    key = OpenSSL::Digest::SHA256.digest('')
    
    ciphs = cipher.encrypt_words(key, ["captain", "doctor", "captain"])
    words = cipher.decrypt_words(key, ciphs)
    
    words.should eql ["captain", "doctor", "captain"]
    
    token = cipher.generate_token(key, "captain")
    cipher.search_exists(token, ciphs).should eql true
    
    cipher.search_words(token, ciphs).should eql [0,2]
    
    token = cipher.generate_token(key, "driver")
    cipher.search_exists(token, ciphs).should eql false
    
    
  end

end