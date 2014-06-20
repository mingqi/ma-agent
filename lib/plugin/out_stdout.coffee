module.exports = () ->
  
  return {
    start : (cb) ->
      console.log "stdout start"
      cb()

    write : (tag, record, time) ->
      console.log "tag=#{tag}, record=#{JSON.stringify(record)}, time=#{time}"
    
    shutdown : (cb) ->
      console.log "stdout shutdown..."          
      cb()
  }
