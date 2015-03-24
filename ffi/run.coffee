ffi = require 'ffi'
ref = require 'ref'

libm = ffi.Library 'libm',
  'ceil': ['double', ['double']]

console.log libm.ceil 1.5

size_t_ptr = ref.refType 'size_t'

libmylib = ffi.Library 'libmylib',
  'set_zero': ['void', [size_t_ptr]]
  'get_str': ['string', ['string', size_t_ptr]]

outNum = ref.alloc 'size_t'

libmylib.set_zero outNum

console.log libmylib.get_str "supercalifragilisticexpialodocious", outNum

console.log outNum.deref()
