m = {}

n = {}

function m.registerCallback(callback)
  m.callback = callback
end

function m.speak(name, line)
  m.callback(name, line)
end

return m
