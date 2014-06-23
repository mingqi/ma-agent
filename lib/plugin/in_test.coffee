mysql  = require('mysql');

module.exports = (config) ->

  count = 0
  query = (emit) ->
      emit({
        tag: 'tsd'
        record: { count: count+=1 }
        })

  return {
    start : (emit, cb) ->
      console.log "intest start..."
      interval_obj = setInterval(query, config.interval * 1000, emit)
      # emit({
      #   tag: 'tsd'
      #   record: { count: count+=1 }
      #   })
      cb()
    
    shutdown : (cb) ->
      console.log "intest shutdonw... #{interval_obj}"
      clearInterval(interval_obj) if interval_obj
      cb()
  }