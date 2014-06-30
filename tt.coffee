Engine = require './lib/engine'
stdout = require './lib/plugin/out_stdout'
in_test = require './lib/plugin/in_test'

in1 = in_test({tag:'test',interval: 1})
# in2 = in_test({tag:'test',interval: 1})
out1 = stdout()
engine = Engine()
engine.addInput(in1)
# engine.addOutput('test', stdout())

engine.start((err) ->
  console.log "engine started: #{err}"
  # engine.addInput(in2)
)

setTimeout(
  () ->
    engine.addOutput('test', out1)
  , 3000 
  )

setTimeout(
  () ->
    engine.removeInput(in1, (err) ->
      console.log err
    )
  , 6000 
  )

