#include <node.h>
#include "node-object-stream.h"

using namespace v8;

void InitAll(Handle<Object> exports) {
  JSONParseStream::Init(exports);
}

NODE_MODULE(parse_stream, InitAll)
