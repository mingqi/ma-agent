module.exports = (config) ->
  interval_obj = null
  count = 0
  monitor = config.monitor

  query = (emit) ->
      emit({
        tag: config.tag
        record: { metric: monitor, value: count+=1 }
        })

  return {
    start : (emit, cb) ->
      console.log "intest start..."
      interval_obj = setInterval(query, config.interval * 1000, emit)
      cb()
    
    shutdown : (cb) ->
      console.log "intest shutdonw... #{interval_obj}"
      clearInterval(interval_obj) if interval_obj
      cb()
  }