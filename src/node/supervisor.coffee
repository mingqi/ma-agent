spawn = require('child_process').spawn
fork = require('child_process').fork
util = require './util'
running = require('is-running')

exports.Supervisor = Supervisor = (script, args, watch_time, wait_time) ->  
  env = process.env
  env.__supervisor_child = true;
  opts = {
    cwd : process.cwd
    env : env
  }

  child = null
  can_restart = false

  forkChild = (is_first, callback) ->
    callback = (() -> ) if not callback
    # child = spawn(process.execPath, [script].concat(args), opts)
    child = fork(script, args, opts)

    if is_first
      util.wait(100, watch_time
      , () ->
          not running(child.pid)     
      , (err, not_running) ->
          if not_running
            callback(new Error("child process quit in #{watch_time}"))
          else
            callback()
      )

    child.on('exit', (code, signal) ->
      return if not can_restart 
      setTimeout(() ->
        process.nextTick(forkChild)
      , wait_time
      )
    )

  killChild =  (callback) ->
    util.kill(child.pid, 3000, callback )

  sendHeartbeat = () ->
    setInterval(() ->
      child.send('heartbeat') if child.connected
    , 500
    )
  
 
  return {
    run : (callback) ->
      forkChild(true, (err) ->
        if not err
          can_restart = true
          sendHeartbeat()
        callback(err)
      )

      process.on('SIGTERM', () ->
        can_restart = false
        killChild(() ->
          process.exit()        
        )
      )
      
      process.on('SIGINT', () ->
        can_restart = false
        killChild(() ->
          process.exit()
        )
      )
  }

exports.checkHeartbeat = checkHeartbeat = (timeout) ->
  last_heartbeat = null
  process.on('message', (msg) ->
    return if msg != 'heartbeat' 
    last_heartbeat = util.systemTime()
  )

  setInterval(() ->
    return if not last_heartbeat
    if (util.systemTime() - last_heartbeat ) > timeout
      logger.warn "too long not receive parent heartbeat, quit."
      process.exit()
  , 500
  )