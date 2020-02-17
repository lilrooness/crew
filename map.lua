local items = require "items"

local m = {
    rooms = {},
    doors = {},
    room_types = {
        "engines",
        "cryo",
        "bridge",
        "weapons"
    }
}

local n = {}


function m.randomWalk(steps)

    local xpos = 200
    local ypos = 300

    local xstep = 105
    local ystep = 105

    local firstRoom = n.createRoom(xpos, ypos, xstep-5, ystep-5)
    firstRoom.isVisible = true
    firstRoom.warning = nil
    table.insert(m.rooms, firstRoom)
    local currentRoom = table.getn(m.rooms)

    -- we will check this map to see if we have collided with ourselves
    local taken = {
        [xpos..":"..ypos] = currentRoom
    }

    -- we can go up and down each axis
    local options = {-1, 1}

    for i=0, steps do

        local direction = options[math.random(#options)]

        if math.random(2) == 1 then
            xpos = xpos + (xstep * direction)
        else
            ypos = ypos + (ystep * direction)
        end


        if taken[xpos..":"..ypos] == nil then
            local room = n.createRoom(xpos, ypos, xstep-5, ystep-5)
            table.insert(m.rooms, room)
            newRoom = table.getn(m.rooms)
            n.addDoor(currentRoom, newRoom, false)
            taken[xpos..":"..ypos] = newRoom
            currentRoom = newRoom

        else
            currentRoom = taken[xpos..":"..ypos]
        end
    end

end


function n.createRoom(x, y, w, h)
  local warning = nil
  if math.random(100) > 50 then
    warning = "hazard"
  end

  local roomItems = {}
  if  math.random(100) > 75 then
    roomItems = {items[items.itemNames[math.random(#items.itemNames)]]}
  end

--  roomItems = {items.t1Scanner.new()}

  return {
    items = roomItems,
    isVisible = false,
    outlineVisible = false,
    x = x,
    y = y,
    w = w,
    h = h,
    type = m.room_types[math.random(#m.room_types)],
    warning = warning,
  }
end

function n.addDoor(room1, room2, isOpen)
    local door = {
        isOpen = isOpen,
        room1 = room1,
        room2 = room2
    }

    table.insert(m.doors, door)
    index = table.getn(m.doors)

    return index
end

return m
