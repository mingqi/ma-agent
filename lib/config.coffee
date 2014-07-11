fs = require 'fs'
glob = require 'glob'
path = require 'path'
us = require 'underscore'
os = require 'os'
http = require 'http'
VError = require('verror');
zlib = require 'zlib'
hoconfig = require 'hoconfig-js'
util = require './util'

exports.local = local = (local_path, cb) ->
  if not fs.existsSync(local_path)
    return cb(new Error("not exists dir or file on #{local_path}"))

  stat = fs.statSync(local_path) 
  if stat.isFile()
    config = hoconfig(options.config_file)
  else
    config = us.reduce(
      glob.sync(path.join(local_path, '*.conf')),
      (c, file) ->
        us.extend(c, hoconfig(file))
      , 
      {}) 
  config = for metric, config_item of config
    us.extend(config_item, {metric: metric}) 
  cb(null, config)


exports.remote = remote= (host, port, licenceKey, cb) ->
  util.rest(
    {
      host: host 
      port: port
      method: 'GET'
      path: /monitor/+os.hostname()
      headers : {
        'licenseKey' : licenceKey
      }    
    }
  , (err, status, result) ->
      if err
        return cb(VError(err, "failed to call remote service grab montior list"))       
      if status != 200
        return cb(new Error("call /montor return error status #{status}"))
      cb(null, result)
  )



exports.remote_backup = (host, port, backup_path, callback) ->
  remote(host, port, (err, config) ->
    if not err 
      fs.writeFile(backup_path, JSON.stringify(config), (err) ->
        if err
          callback(Verror(e, "failed to backup config to local #{backup_path}"))      
        else
          callback(null, config)
      )  
    else
      callback(err)
  )
