local mapUtils = require("map_utils")

m = {}
n = {}

function m.create(person, room)
  return {
    selected = 0,
    table
  }
end

function m.personMenu(gameState, personId)
  local roomId = gameState.people[personId].room
  local room = gameState.map.rooms[roomId]

  local doorIds = mapUtils.getDoorsForRoom(gameState, roomId)

  options = {
    exit = function()
      gameState.currentMenu = nil
      gameState.gameMode = 1
    end
  }

  for i, v in pairs(doorIds) do
    if gameState.map.doors[v].isOpen then
      options["close door "..v] = function()
        n.closeDoor(gameState.people[personId], v, gameState)
        options.exit()
      end
      options["move through "..v] = function()
        n.moveRoom(gameState.people[personId], mapUtils.getOpposingRoomId(v, roomId, gameState), gameState)
        options.exit()
      end
    else
      options["open door "..v] = function()
        n.openDoor(gameState.people[personId], v, gameState)
        options.exit()
      end
    end
  end

  

  return {
    options = options,
    selected = "exit"
  }
end

function m.selectPreviousOption(menu)
  local selectedOptionNumber = 1
  for i, v in pairs(menu.options) do
    if menu.selected == i then
      break
    end

    selectedOptionNumber = selectedOptionNumber + 1
  end

  newSelection = selectedOptionNumber
  if selectedOptionNumber > 1 then
    newSelection = selectedOptionNumber - 1
  end

  local count = 1
  for i, v in pairs(menu.options) do
    if  count == newSelection then
      menu.selected = i
      break;
    end

    count = count + 1
  end
end

function m.selectNextOption(menu)
  local selectedOptionNumber = 1
  for i, v in pairs(menu.options) do
    if menu.selected == i then
      break
    end

    selectedOptionNumber = selectedOptionNumber + 1
  end

  newSelection = selectedOptionNumber
  if selectedOptionNumber < n.countOptions(menu.options) then
    newSelection = selectedOptionNumber + 1
  end

  local count = 1
  for i, v in pairs(menu.options) do
    if  count == newSelection then
      menu.selected = i
      break;
    end

    count = count + 1
  end
end

function m.renderMenu(menu)
  local xSize = 150
  local ySize = n.countOptions(menu.options) * 20
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill", 10, 10, xSize, ySize)
  love.graphics.setColor(1,1,1)
  love.graphics.rectangle("line", 10, 10, xSize, ySize)

  local yCoord = 15
  for i, v in pairs(menu.options) do
    love.graphics.setColor(1,1,1)
    if i == menu.selected then
      love.graphics.rectangle("fill", 15, yCoord, xSize, 15)
      love.graphics.setColor(0,0,0)
    end
    love.graphics.print(i, 15, yCoord)
    yCoord = yCoord + 15
  end
end

function n.countOptions(options)

  local count = 0
  for i, v in pairs(options) do
    count = count + 1
  end

  return count
end

function n.openDoor(person, door_id, gameState)
  if person.state == nil and not gameState.map.doors[door_id].isOpen then
    local ticksLeft = 10
    radio.speak(person.name, lines.door.calm_door_open(door_id))
    person.state = function(dt)
      local done = ticksLeft < 1 or gameState.map.doors[door_id].isOpen -- door may have been opened by someone else

      ticksLeft = ticksLeft - 1

      if done then
        gameState.map.doors[door_id].isOpen = true
        radio.speak(person.name, lines.door.calm_door_opened(door_id))
        person.oxygen = person.oxygen - (math.random(4) + 4)

      end

      return done
    end
  end
end

function n.closeDoor(person, door_id, gameState)
  if person.state == nil and gameState.map.doors[door_id].isOpen then
    local ticksLeft = 10
    radio.speak(person.name, lines.door.calm_door_close(door_id))
    person.state = function(dt)
      local done = ticksLeft < 1 or (not gameState.map.doors[door_id].isOpen) -- door may have been closed by someone else

      ticksLeft = ticksLeft - 1

      if done then
        gameState.map.doors[door_id].isOpen = false
        radio.speak(person.name, lines.door.calm_door_closed(door_id))
        person.oxygen = person.oxygen - (math.random(4) + 4)
      end

      return done
    end
  end
end

function n.moveRoom(person, room_id, gameState)
  if gameState.map.doors[mapUtils.getConnectingDoor(person.room, room_id, gameState)].isOpen then
    local ticksLeft = 3
    person.state = function(dt)
      local done = ticksLeft < 1

      ticksLeft = ticksLeft - dt

      if done then
        person.room = room_id
        gameState.map.rooms[room_id].isVisible = true
        person.oxygen = person.oxygen - (math.random(4) + 4)
      end

      return done
    end
  end
end

return m
