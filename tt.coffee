async = require 'async'

retry = 0
###
async.forever(
  (next) ->
    if retry < 3
      console.log "retry = #{retry}"
      setTimeout(next, 1000) 
      retry +=1
    else
      next("")
  ,
  (err) ->
    console.log "finished" 
)

###

f = () ->
  async.whilst(
    () ->
      retry < 3
    ,

    (cb) ->
      console.log "doing something...."
      retry +=1
      setTimeout(cb, 1000) 
    , 
    (err) ->
       console.log "done #{err}"
      
    )

retry = (times, wait_sec, task, cb) ->
  did = 0 
  async.retry(times,
    (cb) ->
      task((err) ->
        did += 1
        if not err
          cb()
        else
          setTimeout(
            () ->
              cb(err) 
            , 
            1000 * wait_sec * (2 ** (did - 1) )
            ))
    ,
    cb
    )

###
retry = (times, wait_sec, task) ->
  retry = 0
  success = false
  async.whilst(
    () ->
      retry < times || success
    ,
    (cb) ->
      console.log "doing something"
      retry +=1
      cb('')
    ,
    (err) ->
      console.log "done #{err}"
  )
###


tt = () ->
  count = 0
  return (cb) ->
    console.log "doing #{count} ..."
    count +=1 
    if count > 4
      cb()
    else
      cb(count)
  
  

# retry(3, 1, (cb) ->
#   console.log "doming ..."
#   cb() 
# )

# retry(5, 1, tt(), (err) ->
#   console.log err
# )


ff = ({name: n, title: t }) -> 
  console.log n
  console.log t

ff({name : 'mingqi' , title: 'sde'})