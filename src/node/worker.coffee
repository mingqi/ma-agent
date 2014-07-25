counter = 0
exec = () ->
  counter += 1
  if counter < 5
    console.log "running #{counter}" 
  else
    throw new Error("has some exception")


setInterval(exec, 1000)