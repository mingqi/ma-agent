Tail = require('tail').Tail
xregexp = require('xregexp').XRegExp

module.exports = (config) ->
  tail = null
  return {
    start : (emit, cb) ->
      tail = new Tail(config.path);
      x = xregexp(config.pattern)
      tail.on("line", (line) -> 
        m = xregexp.exec(line, x)
        if m and m.value
          emit("tsd", {metric: config.metric, value: parseInt(m.value)})
      );
      
      cb()

    shutdown : (cb) ->
      console.log "tail shutdonw..."
      cb()
  }