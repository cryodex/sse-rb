#include <ruby.h>

/*
 * Helper method to print byte arrays in hex format.
 */
void print_hex(const char* header, const unsigned char *bytes, int len) {
  
  int i = 0; printf("\n%s (%d): ", header, len);
  for (i = 0; i < len; ++i) printf("%x", bytes[i]);
  printf("\n");
  
}

static VALUE sse_rb;
static VALUE sse_rb_cipher;

/* 
 * Initialize an SIV::Cipher object with a key.
 * Performs basic length validation on the key.
 */
static VALUE sse_rb_initialize(VALUE self, VALUE key) {
 
  int keyLen;
  
  // Replace key value with key.to_str
  StringValue(key);
  
  // Get the key length as an int.
  keyLen = RSTRING_LEN(key);
  
  // Make sure key is not empty
  if (keyLen == 0) {
    rb_raise(rb_eArgError, "Key must be non-empty.");
  }
  
  // Set key as instance variable
  rb_iv_set(self, "@key", key);
  
  return self;
  
}

void Init_wrapper(void) {
  
	sse_rb = rb_define_module("SSE");
	
	sse_rb_cipher = rb_define_class_under(sse_rb, "Cipher", rb_cObject);
	
	rb_define_method(sse_rb_cipher, "initialize", sse_rb_initialize, 1);
	//rb_define_method(sse_rb_cipher, "encrypt", sse_rb_encrypt, 2);
	//rb_define_method(sse_rb_cipher, "decrypt", sse_rb_decrypt, 2);
	
  return;
	
}
