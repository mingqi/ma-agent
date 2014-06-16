
module.exports = (config) ->

  query = (emit) ->
    emit("test", {message : 'this is for test'})

  return {
    start : (emit) ->
      setInterval(query, config.interval * 1000, emit)
    
    shutdown : () ->
      console.log "shutdonw..."
  }