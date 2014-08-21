async = require 'async'

async.series [
  (callback) ->
    console.log "this is one"
    callback()

  (callback) ->
    console.log "this is two"
    callback()
  ]
, (err) ->
    console.log err
  