##sse-rb

This gem implements symmetric searchable encryption, as described in [Song et al, 2000](http://www.cs.berkeley.edu/~dawnsong/papers/se.pdf). This scheme provides a provably secure, simple and fast algorithm for searching over encrypted data. Instead of the custom deterministic encryption scheme described in the paper, this implementation uses deterministic authenticated encryption with AES-SIV.

###Usage

```ruby
require 'sse'

key = OpenSSL::Digest::SHA256.digest('')
cipher = SSE::Cipher.new(key)

ciphs = cipher.encrypt_words(key, ["captain", "doctor", "captain"])
words = cipher.decrypt_words(key, ciphs)

puts words == ["captain", "doctor", "captain"] # => true
                                                 
token = cipher.generate_token(key, "captain")    
puts cipher.search_exists(token, ciphs)        # => true
                                                 
puts cipher.search_words(token, ciphs)         # => [0,2]

token = cipher.generate_token(key, "driver")
puts cipher.search_exists(token, ciphs)        # => false

```

###Credits

A [Javascript implementation](https://github.com/wanasit/searchable-encryption-js) provided insight into several implementation details. [CryptDB](http://g.csail.mit.edu/cryptdb/) provided a reference implementation for the Song et al. paper. 

###License

This software is released under the GNU Affero General Public License. If this license does not suit your needs, please contact me.