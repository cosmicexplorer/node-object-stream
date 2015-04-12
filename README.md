simple-object-stream
==================

This is a simple stream implementing node's Transform interface. It parses an input stream and emits `'object'` events with parsed JSON objects when it reaches a full JSON object, and errors out when it encounters invalid JSON.

# To use:

```javascript
var SimpleObjectStream = require('simple-object-stream');
var objectStream = getReadableStreamSomehow().pipe(new SimpleObjectStream);

// gives you a tidy little javascript object
objectStream.on('object', function(obj){
  doSomethingWithObject(obj);
});

// fires when stream has no more data
objectStream.on('end', function(){
  doSomethingWhenStreamIsDone();
});

// uh oh! something bad happened!!!
objectStream.on('error', function(){
  doSomethingOnError();
});

```

As it inherits from the Transform stream interface, this stream can use both the standard readable and writable interfaces detailed in the [node documentation](https://nodejs.org/api/stream.html). Its output can also be piped to another stream, although its stream output isn't parsed into json objects the way its emitted 'object' events do.

Note that this stream will error out if passed anthing but braced JSON objects (hashes and arrays: objects starting with {} or []). While more advanced functionality could be added, this would make the goal of simplicity difficult to achieve.

# Development

I wrote this because I once spent seven hours at a hackathon trying to get IPC going between a python and a node process. If you think there's something that needs to be added, feel free to send an email, issue, pull request, smoke signal, whatever. If any speed issues ever arise, I'll probably manually construct the JSON instead of calling JSON.parse(), and maybe play with some C functions as required.

# License

This is GPL, duh.

Thanks for stopping by!
