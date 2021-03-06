// ..........................................................
// DEBUG - this is only included in debug mode
//

// Identify opal as being in debug mode
opal.debug = true;

// Holds the default debug tools. These are what are used by default inside
// opal when debugging. They can be overriden as appropriate options to
// main().
var debugging = {

  // default backtrace in debugging mode is the 'opal' backtrace, which
  // uses its own debug stack
  backtrace: function(err) {
    var result = [],
        stack  = err.opal_stack || [],
        frame,
        recv,
        meth;

    for (var i = stack.length - 1; i >= 0; i--) {
      frame = stack[i];
      meth  = frame.meth;
      recv  = frame.recv;
      klass = meth.$debugKlass;

      if (recv.o$flags & T_OBJECT) {
        recv = class_real(recv.o$klass);
        recv = (recv === klass ? recv.o$name : klass.o$name + '(' + recv.o$name + ')') + '#';
      }
      else {

        recv = recv.o$name + '.';
      }

      result.push('from ' + recv + jsid_to_mid(frame.jsid) + ' at ' + meth.$debugFile + ':' + meth.$debugLine);
    }

    return result;
  },

  // Send a ruby method call
  send: function(recv, jsid) {
    var args    = $slice.call(arguments, 2),
        meth    = recv[jsid];

    if (!meth) {
      args = $slice.call(args, 1);
      args.unshift(jsid_to_mid(jsid));
      args.unshift(null);
      return recv.$method_missing.apply(recv, args);
    }

    // Push this call frame onto debug stack
    debug_stack.push({
      recv: recv,
      jsid: jsid,
      meth: meth
    });

    try {
      var result = meth.apply(recv, args);
    }
    catch (err) {
      if (!err.opal_stack) {
        err.opal_stack = debug_stack.slice();
      }

      throw err;
    }
    finally {
      debug_stack.pop();
    }

    return result;
  }
};

var vanilla = {
  backtrace: function(err) {
    return ['No backtrace available'];
  },

  send: function(recv, jsid) {
    var args = $slice.call(arguments, 2),
        meth = recv[jsid];

    if (!meth) {
      throw new Error('undefined method `' + jsid_to_mid(jsid) + '\' for ' + recv);
    }

    return meth.apply(recv, args);
  }
}

// Use standard debugging send for initial boot up, but we can override it
// inside main() to use a custom sender
opal.send = debugging.send;

opal.backtrace = debugging.backtrace;

// An array of every method send in debug mode
var debug_stack = [];

var release_define_method = define_method;

define_method = opal.defn = function(klass, id, body, file, line) {

  if (!body.$debugFile) {
    body.$debugFile  = file;
    body.$debugLine  = line;
    body.$debugKlass = klass;
  }

  return release_define_method(klass, id, body);
};

var release_main = opal.main;

opal.main = function(id, opts) {
  opts = (opts || {});

  // Default to normal debugging send
  opal.send = debugging.send;

  if (opts.vanilla) {
    opal.send = vanilla.send;
    opal.backtrace = vanilla.backtrace;
    release_main(id);
  }
  else {
    try {
      release_main(id);
    }
    catch (e) {
      var str = e.o$klass.o$name + ': ' + e.message;
      str += "\n\t" + e.$backtrace().join("\n\t");
      console.error(str);
    }
  }
};

//function debug_get_backtrace(err) {
  //if (true) {
    //var old = Error.prepareStackTrace;
    //Error.prepareStackTrace = debug_chrome_build_stacktrace;
    //var stack = err.stack || [];

    //Error.prepareStackTrace = old;
    //return stack;
  //}

  //return ['No backtrace available'];
//}

//function debug_chrome_stacktrace(err, stack) {
  //return debug_chrome_build_stacktrace(err, stack).join('');
//}

//function debug_chrome_build_stacktrace(err, stack) {
  //var code = [], f, b, k, name, recv, str, klass;

  //try {
  //for (var i = 0; i < stack.length; i++) {
    //f = stack[i];
    //b = f.getFunction();
    //name = f.getMethodName();
    //recv = f.getThis();
    //str  = ""

    //if (!recv.o$klass || !name) {
      //str = f.getFunctionName();
    //}
    //else {
      //klass = b.$debugKlass;
      //if (klass && recv.o$flags & T_OBJECT) {
        //recv = class_real(recv.o$klass);
        //recv = (recv === klass ? recv.o$name : klass.o$name + '(' + recv.o$name + ')') + '#';
      //}
      //else {

        //recv = recv.o$name + '.';
      //}

      ////code.push("from " + self + jsid_to_mid(name) + ' at ' + f.getFileName() + ":" + f.getLineNumber());

      //// real filename/linenumber in js
      ////str = recv + jsid_to_mid(name) + ' at ' + b.$debugFile + ":" + b.$debugLine;
      //str = recv + jsid_to_mid(name);
    //}

    //code.push("from " + str + " (" + f.getFileName() + ":" + f.getLineNumber() + ")");
  //}

  //return code;
  //}
  //catch (e) {
    //return [];
  //}
  ////var result = [],
      ////frame,
      ////recv,
      ////meth;

  ////for (var i = stack.length - 1; i >= 0; i--) {
    ////frame = stack[i];
    ////meth  = frame.meth;
    ////recv  = frame.recv;
    ////klass = meth.$debugKlass;

    ////if (recv.o$flags & T_OBJECT) {
      ////recv = class_real(recv.o$klass);
      ////recv = (recv === klass ? recv.o$name : klass.o$name + '(' + recv.o$name + ')') + '#';
    ////}
    ////else {

      ////recv = recv.o$name + '.';
    ////}

    ////result.push('from ' + recv + jsid_to_mid(frame.jsid) + ' at ' + meth.$debugFile + ':' + meth.$debugLine);
  ////}

  ////return result;
//}
