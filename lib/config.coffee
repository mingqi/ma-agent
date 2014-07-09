fs = require 'fs'
glob = require 'glob'
path = require 'path'
us = require 'underscore'
os = require 'os'
http = require 'http'
VError = require('verror');
zlib = require 'zlib'
hoconfig = require 'hoconfig-js'

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
  buffs = []
  options = {
      host: host 
      port: port
      method: 'GET'
      path: /aconfig/+os.hostname()
      headers : {
        'Accept-Encoding' : 'gzip'
        'licenseKey' : licenceKey
      }
    }

  req = http.request(options, (res) ->
    res.on('data', (chunk) -> 
      buffs.push chunk
    ) 

    res.on('end',  () ->
      buffer = Buffer.concat(buffs);
      zlib.gunzip(buffer, (err, result) ->

        if err
          cb(VError(err, "failed to gunzip server response, content length #{buffer.length}"))       
        else
          try
            config = JSON.parse(result)
          catch e
            return cb(new VError(e, "failed parse json object"))
          cb(null, config)
      )
    )
  )

  req.on('error', (e) ->
    cb(new VError(e, "failed to send data to #{remote}:#{port}"))
  )

  req.end()

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
