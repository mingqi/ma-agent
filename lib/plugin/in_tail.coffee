Tail = require('../tail').Tail
xregexp = require('xregexp').XRegExp
glob = require 'glob'
path = require 'path'
us = require 'underscore'
dirty = require 'dirty'
util = require 'util'

module.exports = (config) ->
  tails = {}
  posdb = null
  flush_interval = null

  unwatch = (p) ->
    mem = tails[p].unwatch()
    delete tails[p] 
    return mem
  
  globFiles = (_path) ->
    glob.sync(_path).map(
      (f) ->
        try
          path.resolve(f) 
        catch e
          console.log e.stack      
        # console.log path
    )

  flushTails =  (listener) ->
    curr_paths = us.keys(tails)
    target_paths = globFiles(config.path)
    to_add = us.difference(target_paths, curr_paths) 
    to_remove = us.difference(curr_paths, target_paths)
    for f in to_add
      console.log f
      tails[f] = new Tail(f, {start: 0})
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
      posdb = dirty(config.posfile) 
      posdb.on('load', () ->
        for f in globFiles(config.path)
          mem = posdb.get(f)
          if mem
            tail_options = {start: mem.pos, inode: mem.inode}
          else
            tail_options = {}
          tails[f] = new Tail(f, tail_options)
          tails[f].on('line', online)
        flush_interval = setInterval(flushTails, 1000, online, {start: 0}) 
        cb()
      )

    shutdown : (cb) ->
      console.log "tail shutdonw..."
      if flush_interval
        clearInterval(flush_interval)
      for _path, tail of tails 
        posdb.set(_path, unwatch(_path)) 
      cb()
  }