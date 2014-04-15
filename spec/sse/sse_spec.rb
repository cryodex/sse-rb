require 'spec_helper'
require 'sse'

describe SSE do
  
  it "should provide basic functionality" do
    
    key = ["fffefdfcfbfaf9f8f7f6f5f4f3f2f1f0f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"].pack("H*")
    
    cipher = SSE::Cipher.new(key)
    
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