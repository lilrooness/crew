m = {}

function m.getConnectingDoor(room1, room2, gameState)
  for i, v in pairs(gameState.map.doors) do
    if (v.room1 == room1 and v.room2 == room2) or (v.room2 == room1 and v.room1 == room2) then
      return i
    end
  end

  return nil
end

function m.getDoorsForRoom(gameState, roomId)
  local doorIds = {}

  for i, v in pairs(gameState.map.doors) do
    if v.room1 == roomId or v.room2 == roomId then
      table.insert(doorIds, i)
    end
  end

  return doorIds
end

function m.getOpposingRoomId(doorId, currentRoomId, gameState)
  if gameState.map.doors[doorId].room1 == currentRoomId then
    return gameState.map.doors[doorId].room2
  elseif gameState.map.doors[doorId].room2 == currentRoomId then
    return gameState.map.doors[doorId].room1
  end

  print("ERROR - COULD NOT GET ROOM OPPOSING ROOM: "..cuurentRoomId..". NOT CONNECTED TO DOOR: "..doorId)
  return nil
end

return m
