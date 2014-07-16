spawn = require('child_process').spawn
util = require './util'
running = require('is-running')

module.exports = Supervisor = (script, args, watch_time, wait_time) ->  
  env = process.env
  env.__supervisor_child = true;
  opts = {
    cwd : process.cwd
    env : env
    stdio: 'inherit'
  }

  child = null
  can_restart = false

  fork = (is_first, callback) ->
    callback = (() -> ) if not callback
    child = spawn(process.execPath, [script].concat(args), opts)

    if is_first
      util.wait(100, watch_time
      , () ->
          not running(child.pid)     
      , (err, not_running) ->
          if not_running
            callback(new Error("child process quit in #{watch_time}"))
          else
            can_restart = true
            callback()
      )

    child.on('exit', (code, signal) ->
      return if not can_restart 
      setTimeout(() ->
        process.nextTick(fork)
      , wait_time
      )
    )

  killChild =  (callback) ->
    util.kill(child.pid, 3000, callback )
  
 
  return {
    run : (callback) ->
      fork(true, callback)

      process.on('SIGTERM', () ->
        killChild(() ->
          process.exit()        
        )
      )
      
      process.on('SIGINT', () ->
        killChild(() ->
          process.exit()
        )
      )
  }
