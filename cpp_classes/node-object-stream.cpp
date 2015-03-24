#include <iostream>

#include "node-object-stream.h"

using namespace v8;

Persistent<Function> JSONParseStream::constructor;

JSONParseStream::JSONParseStream(double value) : value_(value) {
}

JSONParseStream::~JSONParseStream() {
}

void JSONParseStream::Init(Handle<Object> exports) {
  Isolate * isolate = Isolate::GetCurrent();

  // Prepare constructor template
  Local<FunctionTemplate> tpl = FunctionTemplate::New(isolate, New);
  tpl->SetClassName(String::NewFromUtf8(isolate, "JSONParseStream"));
  tpl->InstanceTemplate()->SetInternalFieldCount(1);

  // Prototype
  NODE_SET_PROTOTYPE_METHOD(tpl, "plusOne", PlusOne);
  NODE_SET_PROTOTYPE_METHOD(tpl, "_transform", _transform);

  constructor.Reset(isolate, tpl->GetFunction());
  exports->Set(String::NewFromUtf8(isolate, "JSONParseStream"),
               tpl->GetFunction());
}

void JSONParseStream::New(const FunctionCallbackInfo<Value> & args) {
  Isolate * isolate = Isolate::GetCurrent();
  HandleScope scope(isolate);

  if (args.IsConstructCall()) {
    // Invoked as constructor: `new JSONParseStream(...)`
    double value = args[0]->IsUndefined() ? 0 : args[0]->NumberValue();
    JSONParseStream * obj = new JSONParseStream(value);
    obj->Wrap(args.This());
    args.GetReturnValue().Set(args.This());
  } else {
    // Invoked as plain function `JSONParseStream(...)`, turn into construct
    // call.
    const int argc = 1;
    Local<Value> argv[argc] = {args[0]};
    Local<Function> cons = Local<Function>::New(isolate, constructor);
    args.GetReturnValue().Set(cons->NewInstance(argc, argv));
  }
}

void JSONParseStream::PlusOne(const FunctionCallbackInfo<Value> & args) {
  Isolate * isolate = Isolate::GetCurrent();
  HandleScope scope(isolate);

  JSONParseStream * obj = ObjectWrap::Unwrap<JSONParseStream>(args.Holder());
  obj->value_ += 1;

  args.GetReturnValue().Set(Number::New(isolate, obj->value_));
}

void JSONParseStream::_transform(const FunctionCallbackInfo<Value> & args) {
  Isolate * isolate = Isolate::GetCurrent();
  HandleScope scope(isolate);
  JSONParseStream * obj = ObjectWrap::Unwrap<JSONParseStream>(args.Holder());

  // (chunk, encoding, callback)
  if (args[3]->IsUndefined()) {
    Handle<Value>
    std::cout << "";
  } else {
    Local<Function> cb = Local<Function>::Cast(args[2]);
    const unsigned argc = 0;
    Local<Value> argv[argc] = {};
    cb->Call(Context::GetCurrent(), argc, argv);
    return scope.Close(Undefined());
  }
}
