vm = require 'vm'
Server = require("mongo-sync").Server;
Fiber = require('fibers');

module.exports = (mg_opts, command, callback) ->
  ###
  mg_opts:
    host
    port
    database
    user
    pwd
  ###

  r = /db.([A-Za-z0-9_\-.]*).(count|find|findOne)/.exec(command)
  if not r
    return callback(new Error("wrong mongo query format '#{command}', format should be db.<collection>.<query>}")) 

  collection = r[1]
  code  = "coll."+command.substring(4+collection.length) 

  server = new Server("#{mg_opts.host}:#{mg_opts.port}");

  Fiber( () ->
    try
      db = server.db(mg_opts.database)
      if mg_opts.user? and mg_opts.user.trim().length > 0
        try
          db.auth(mg_opts.user, mg_opts.pwd)
        catch e
          return callback(new Error("database authentication failed")) 
      db_coll = db.getCollection(collection)

      find = db_coll.find
      findOne = db_coll.findOne
      count = db_coll.count
      new_db_coll = {
        find : () ->
          find.apply(db_coll, arguments)

        findOne : () ->
          find.apply(db_coll, arguments)

        count: () ->
          count.apply(db_coll, arguments)
        
      }

      db[collection] = new_db_coll

      sandbox = 
        coll : new_db_coll
        callback : callback

      result = vm.runInNewContext(code, sandbox)  

      if result.toArray?
        callback(null, result.toArray())
      else
        callback(null, result)
    catch e
      return callback(e)      
    finally
      server.close()

    server.close() 
  ).run()

