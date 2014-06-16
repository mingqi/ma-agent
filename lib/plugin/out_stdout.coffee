module.exports = () ->
  
  return {

    receive : (tag, record, time) ->
      console.log "tag=#{tag}, record=#{JSON.stringify(record)}, time=#{time}"
    
    shutdown : () ->
      console.log "stdout shutdown..."          
  }
