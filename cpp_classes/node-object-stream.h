#ifndef MYOBJECT_H
#define MYOBJECT_H

#include <node.h>
#include <node_object_wrap.h>

class JSONParseStream : public node::ObjectWrap {
 public:
  static void Init(v8::Handle<v8::Object> exports);

 private:
  explicit JSONParseStream(double value = 0);
  ~JSONParseStream();

  static void New(const v8::FunctionCallbackInfo<v8::Value>& args);
  static void PlusOne(const v8::FunctionCallbackInfo<v8::Value> & args);
  static void _transform(const v8::FunctionCallbackInfo<v8::Value> & args);
  static v8::Persistent<v8::Function> constructor;
  double value_;
};

#endif
