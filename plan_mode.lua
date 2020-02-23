local m = {}

local n = {
  route = {1},
  selectedRoom = 1,
  scaleFactor = 0,
  selectorX = love.graphics.getWidth() / 2,
  selectorY = love.graphics.getHeight() / 2,
  xGridLines = 0,
  yGridLines = 0
}

function m.renderPlanView(gameState)
  local minX = nil
  local minY = nil
  local maxX = nil
  local maxY = nil

  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()

  local roomWidth = gameState.map.rooms[1].w + 5
  local roomHeight = gameState.map.rooms[1].h + 5

  for i, v in pairs(gameState.map.rooms) do
    if minX == nil then
      minX = v.x
      minY = v.y
      maxX = v.x
      maxY = v.y
    end
    minX = math.min(v.x, minX)
    minY = math.min(v.y, minY)
    maxX = math.max(v.x, maxX)
    maxY = math.max(v.y, maxY)
  end

  local mapHeight = maxY - minY
  local mapWidth = maxX - minX

  local midX = minX + (maxX / 2)
  local midY = minY + (maxY / 2)

  local xScaleFactor = screenWidth / mapWidth / 1.1
  local yScaleFactor = screenHeight / mapHeight / 1.1

  n.scaleFactor = math.min(xScaleFactor, yScaleFactor)
  local xTrans = minX * n.scaleFactor
  local yTrans = minY * n.scaleFactor

  n.xGridLines = love.graphics.getWidth() / (roomWidth * n.scaleFactor)
  n.yGridLines = love.graphics.getHeight() / (roomHeight * n.scaleFactor)

  -- DRAW GRID
  for x = 0, n.xGridLines do
    love.graphics.setColor(0.05, 0.05, 0.05)
    local xpos = x * roomWidth * n.scaleFactor
    love.graphics.line(xpos, 0, xpos, love.graphics.getHeight())
    -- love.graphics.setColor(1, 1, 1)
    love.graphics.print("" .. x, xpos + roomWidth / 2 * n.scaleFactor, 5, 0, 0.65, 0.65)
  end

  for y = 0, n.yGridLines do
    love.graphics.setColor(0.05, 0.05, 0.05)
    local ypos = y * roomHeight * n.scaleFactor
    love.graphics.line(0, ypos, love.graphics.getWidth(), ypos)
    love.graphics.print(n.getLetterCoord(y), 5, ypos + roomHeight / 2 * n.scaleFactor, 0, 0.65, 0.65)
  end

  -- DRAW DOORS
  for i, v in pairs(gameState.map.doors) do
    love.graphics.setColor(1, 0, 0, 0.25)
    room1 = gameState.map.rooms[v.room1]
    room2 = gameState.map.rooms[v.room2]
    love.graphics.line(
      (room1.x + roomWidth / 2) * n.scaleFactor - xTrans,
      (room1.y + roomHeight / 2) * n.scaleFactor - yTrans,
      (room2.x + roomWidth / 2) * n.scaleFactor - xTrans,
      (room2.y + roomHeight / 2) * n.scaleFactor - yTrans
    )
  end

  -- DRAW ROOMS
  for i, v in pairs(gameState.map.rooms) do
    if n.isInTable(i, n.route) then
      love.graphics.setColor(0, 1, 0)
      love.graphics.rectangle(
        "fill",
        (v.x) * n.scaleFactor - xTrans,
        (v.y) * n.scaleFactor - yTrans,
        v.w * n.scaleFactor,
        v.h * n.scaleFactor
      )
    end

    if i == n.selectedRoom then
      love.graphics.setColor(1, 0, 0)
      love.graphics.rectangle(
        "line",
        (v.x) * n.scaleFactor - xTrans,
        (v.y) * n.scaleFactor - yTrans,
        v.w * n.scaleFactor,
        v.h * n.scaleFactor
      )
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.setShader(planModeShader)
    planModeShader:send("random", math.random())
    planModeShader:send("goalRoom", v.goalRoom)
    if v.goalRoom then
      love.graphics.rectangle(
        "fill",
        (v.x) * n.scaleFactor - xTrans,
        (v.y) * n.scaleFactor - yTrans,
        v.w * n.scaleFactor,
        v.h * n.scaleFactor
      )
    else
      love.graphics.rectangle(
        "line",
        (v.x) * n.scaleFactor - xTrans,
        (v.y) * n.scaleFactor - yTrans,
        v.w * n.scaleFactor,
        v.h * n.scaleFactor
      )
    end

    love.graphics.setShader()
  end
end

function m.processInput(keys, gameState)
end

function n.getLetterCoord(n)
  local letters = {
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z"
  }

  local twentySixs, _frac = math.modf((n + 1) / #letters)
  local ones = ((n + 1) % #letters)

  print("n = " .. n .. " twentysix's = " .. twentySixs .. " ones = " .. ones)

  if twentySixs == 0 then
    return letters[ones]
  else
    return letters[twentySixs] .. letters[ones + 1]
  end
end

function n.isInTable(n, t)
  for i, v in pairs(t) do
    if n == v then
      return true
    end
  end

  return false
end

return m
