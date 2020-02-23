local m = {}

local n = {}

function m.renderPlanView(gameState)
  local minX = 0
  local minY = 0
  local maxX = 0
  local maxY = 0

  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()

  for i, v in pairs(gameState.map.rooms) do
    minX = math.min(v.x, minX)
    minY = math.min(v.y, minY)
    maxX = math.max(v.x, maxX)
    maxY = math.max(v.y, maxY)
  end

  local mapHeight = maxY - minY
  local mapWidth = maxX - minX

  local xScaleFactor = screenWidth / mapWidth
  local yScaleFactor = screenHeight / mapHeight

  local scaleFactor = math.min(xScaleFactor, yScaleFactor) / 2
  local xTrans = screenWidth / 2
  local yTrans = screenHeight / 2

  for i, v in pairs(gameState.map.rooms) do
    love.graphics.setColor(1, 1, 1)
    love.graphics.setShader(planModeShader)
    planModeShader:send("random", math.random())
    planModeShader:send("goalRoom", v.goalRoom)
    if v.goalRoom then
      love.graphics.rectangle(
        "fill",
        (v.x) * scaleFactor + xTrans,
        (v.y) * scaleFactor + yTrans,
        v.w * scaleFactor,
        v.h * scaleFactor
      )
    else
      love.graphics.rectangle(
        "line",
        (v.x) * scaleFactor + xTrans,
        (v.y) * scaleFactor + yTrans,
        v.w * scaleFactor,
        v.h * scaleFactor
      )
    end

    love.graphics.setShader()
  end
end

return m
