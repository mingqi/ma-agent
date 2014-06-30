Tail = require('../tail').Tail
xregexp = require('xregexp').XRegExp
glob = require 'glob'
path = require 'path'
us = require 'underscore'
dirty = require 'dirty'
util = require 'util'
fs = require 'fs'

module.exports = (config) ->
  tails = {}
  posdb = null
  flush_interval = null
  inodes = []

  unwatch = (p) ->
    mem = tails[p].unwatch()
    delete tails[p] 
    return mem
  
  globFiles = (_path) ->
    glob.sync(_path).map((f) -> 
      path.resolve(f)
    )

  flushTails =  (listener) ->
    curr_paths = us.keys(tails)
    target_paths = globFiles(config.path)
    to_add = us.difference(target_paths, curr_paths) 
    to_remove = us.difference(curr_paths, target_paths)
    target_inodes = us.reduce(
      target_paths, 
      (mem,p) -> 
        mem[p] = fs.statSync(p).ino
        return mem
      ,
      {}
      )
    for f in to_add
      inode = target_inodes[f]
      start = if us.contains(inodes, inode) then null else 0
      tails[f] = new Tail(f, {start: start})
      tails[f].on('line', listener)

    inodes = us.values(target_inodes)
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
          inodes.push(fs.statSync(f).ino)
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