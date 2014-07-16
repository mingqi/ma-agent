Supervisor = require '../lib/supervisor'

s = Supervisor('./worker.js', [], 3000, 2000)
s.run((err) ->
  console.log err
)