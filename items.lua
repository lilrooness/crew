local mapUtils = require("map_utils")

local m = {}
local n = {}

m.itemNames = {
  "t1Scanner",
  "o2Tank"
}

m.t1Scanner = {
  name = "T1 Scanner"
}
m.t1Scanner.__index = m.t1Scanner
function m.t1Scanner.new()
  local o = setmetatable({}, m.t1Scanner)
  o.name = m.t1Scanner.name
  return o
end

function m.t1Scanner:__tostring()
  return self.name
end

-- illuminate rooms round current room
function m.t1Scanner:passive(dt, personId, gameState)
  local currentRoomId = gameState.people[personId].room
  local currentRoom = gameState.map.rooms[currentRoomId]

  local currentX = currentRoom.x + currentRoom.w/2
  local currentY = currentRoom.y + currentRoom.h/2

  local xDist = 105
  local yDist = 105

  for i, v in pairs(gameState.map.rooms) do
    local x = v.x + v.w/2
    local y = v.y + v.h/2
    if math.abs(x - currentX) <= xDist and math.abs(y - currentY) <= yDist then
      v.outlineVisible = true
    end
  end
end

m.o2Tank = {
  name = "O2 Tank",
  content = 0
}
m.o2Tank.__index = m.o2Tank
function m.o2Tank.new(content)
  local o = setmetatable({}, m.o2Tank)
  o.name = m.o2Tank.name
  o.content = math.random(100)
  return o
end

function m.o2Tank:__tostring()
  return self.name..": "..self.content.."%"
end

function m.o2Tank:active(personId, gameState)
  local space = 100 - gameState.people[personId].oxygen
  local amountToRefil = math.min(space, self.content)
  self.content = self.content - amountToRefil
  gameState.people[personId].oxygen = gameState.people[personId].oxygen + amountToRefil
end

return m
