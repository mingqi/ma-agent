Tail = require('../tail').Tail
xregexp = require('xregexp').XRegExp
glob = require 'glob'
path = require 'path'
us = require 'underscore'

module.exports = (config) ->
  tails = {}

  unwatch = (p) ->
    tails[p].unwatch()
    delete tails[p] 
  
  globFiles = (_path) ->
    glob.sync(_path).map((f) ->
      path.resolve(f) 
    )

  flushTail =  (listener, from_start) ->
    curr_paths = us.keys(tails)
    target_paths = globFiles(config.path)
    to_add = us.difference(target_paths, curr_paths) 
    to_remove = us.difference(curr_paths, target_paths)
    for f in to_add
      tails[f] = new Tail(f, {start: if from_start then 0 else null})
      tails[f].on('line', listener)

    for f in to_remove
      unwatch(f)


  return {
    start : (emit, cb) ->
      console.log "tail starting..."

      online = (line) -> 
        x = xregexp(config.pattern)
        m = xregexp.exec(line, x)
        if m and m.value
          emit({
            tag: 'tsd',
            record: {metric: config.metric, value: parseInt(m.value)}
          })
      
      flushTail(online, false)
      setInterval(flushTail, 1000, online, true) 
      cb()

    shutdown : (cb) ->
      console.log "tail shutdonw..."
      cb()
  }