engine = require '../lib/engine'

test_input= (name, start_delay, shutdown_delay) ->
  return {
    start : (emit, cb) ->
      setTimeout(
        () ->
          console.log "started #{name}"
          cb()
        ,
        start_delay * 1000
      ) 
    
    shutdown : (cb) ->
      setTimeout(
        () ->
          console.log "shutdown #{name}"
          cb()
        ,
        shutdown_delay * 1000
      ) 
 
  }

test_output= (name, start_delay, shutdown_delay) ->
  return {
    start : (cb) ->
      setTimeout(
        () ->
          console.log "started #{name}"
          cb()
        ,
        start_delay * 1000
      ) 
    
    shutdown : (cb) ->
      setTimeout(
        () ->
          console.log "shutdown #{name}"
          cb()
        ,
        shutdown_delay * 1000
      ) 
 
  }

# input2 = test_input("input2", 2, 2)
# output1 = test_output("output1", 2, 2)
# engine.add_input(test_input("input1", 4, 4))
# engine.add_input(input2)
# engine.add_input(input2)
# engine.add_output("", output1)
# engine.add_output("", output1)
# engine.add_output("", test_output("output2", 1, 2))

# engine.start(() ->
#   console.log "engine already started"  

#   engine.shutdown(() ->
#     console.log "engine already shutdown"
#   )
# )

console.log "aaaaaaaaaaaaaa"
engine.start((err) ->
  console.log "engine started #{err}"
)
engine.add_input(test_input("input1", 1, 1), null, (err, ii) ->
  console.log ii
)
engine.add_input(test_input("input2", 1, 1))

# engine.remove_input(id)
