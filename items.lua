local mapUtils = require("map_utils")

local m = {}
local n = {}

m.t1Scanner = {
  name = "T1 Scanner"
}

-- illuminate rooms round current room
m.t1Scanner.passive = function(dt, personId, gameState)
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

return m
