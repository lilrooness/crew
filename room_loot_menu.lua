local m = {}
local n = {}

function m.roomLootMenu(gameState, personId, roomId)
  local person = gameState.people[personId]
  local room = gameState.map.rooms[roomId]

  local options = {
    exit = function()
      gameState.currentMenu = nil
      gameState.gameMode = 1
    end
  }

  for i, v in pairs(room.items) do
    options[v.name] = function()
      table.insert(person.items, v)
      room.items[i] = nil
      gameState.currentMenu = m.roomLootMenu(gameState, personId, roomId)
    end
  end

  return {
    options = options,
    selected = "exit"
  }
end

return m
