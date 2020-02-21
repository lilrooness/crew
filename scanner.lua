m = {}

n = {
  points = {}
}

function m.initScan(gameState)
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

  for x=0,width do
    for y=0,height do
      if n.insideRoom(x,y, gameState) and math.random(100) > 95 then
        table.insert(n.points, x)
        table.insert(n.points, y)
      elseif math.random(100) > 98 then
        --n.points = n.points..{x, y}
        table.insert(n.points, x)
        table.insert(n.points, y)
      end
    end
  end
end

function n.insideRoom(x, y, gameState)
  for i,v in pairs(gameState.map.rooms) do
    if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
      return true
    end
  end

  return false
end

function m.renderScan(gameState)
--  local intensity = math.random()
  --love.graphics.setColor(intensity, intensity, intensity)
  --love.graphics.points(n.points)

  for i=1,#n.points,2 do
    local intensity = math.random()
    love.graphics.setColor(intensity, intensity, intensity)
    love.graphics.points(n.points[i], n.points[i+1])
  end
end

return m
