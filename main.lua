radio = require "radio"
map = require "map"

keys = {
  w = false,
  a = false,
  s = false,
  d = false
}

updateStep = 1000 / 60
time = 0

textbox = {
    x = 10,
    y = 300,
    w = 500,
    h = 5 * 15
}

local camera_x = 0
local camera_y = 0

lines_collection = {}

for i, v in pairs(radio.door) do
    table.insert(lines_collection, v)
end

for i, v in pairs(radio.chatter) do
    table.insert(lines_collection, v)
end

sentences = {}


people = {}

icons = {}

function getIconQuad(x, y, w, h, image)
    icon_quad = love.graphics.newQuad(x, y, w, h, image:getWidth(), image:getHeight())
end

function createPerson(name, x, y)
    return {
        name = name,
        stressLevel = 0,
        x = x,
        y = y,
        lastUpdated = 0,
        room = 1,
        state = nil
    }
end

function getConnectingDoor(room1, room2)
    for i, v in pairs(map.doors) do
        if (v.room1 == room1 and v.room2 == room2) or (v.room2 == room1 and v.room1 == room2) then
            return i
        end
    end

    return nil
end

function openDoor(person, door_id)
    if person.state == nil and not map.doors[door_id].isOpen then
        local ticksLeft = 10
        speak(person.name, radio.door.calm_door_open(door_id))
        person.state = function(dt)
            local done = ticksLeft < 1 or map.doors[door_id].isOpen -- door may have been opened by someone else

            ticksLeft = ticksLeft - 1

            if done then
                map.doors[door_id].isOpen = true
                speak(person.name, radio.door.calm_door_opened(door_id))
            end

            return done
        end
    end
end

function closeDoor(person, door_id)
    if person.state == nil and map.doors[door_id].isOpen then
        local ticksLeft = 10
        speak(person.name, radio.door.calm_door_close(door_id))
        person.state = function(dt)
            local done = ticksLeft < 1 or (not map.doors[door_id].isOpen) -- door may have been closed by someone else

            ticksLeft = ticksLeft - 1

            if done then
                map.doors[door_id].isOpen = false
                speak(person.name, radio.door.calm_door_closed(door_id))
            end

            return done
        end
    end
end

function moveRoom(person, room_id)
    if map.doors[getConnectingDoor(person.room, room_id)].isOpen then
        local ticksLeft = 3
        person.state = function(dt)
            local done = ticksLeft < 1

            ticksLeft = ticksLeft - dt

            if done then
              person.room = room_id
              map.rooms[room_id].isVisible = true
            end

            return done
        end
    end
end

function updatePerson(person, dt)
    if not (person.state == nil) then
        done = person.state(dt)

        if done then
            person.state = nil
        end
    end
end

function shiftTextUp()
    table.remove(sentences, 1)
end

function speak(name, text)
    if table.getn(sentences) > 4 then
        table.remove(sentences, 1)
    end

    table.insert(sentences, name .. ": " .. text)
end

function love.draw()

    -- ROOMS
    love.graphics.setColor(1, 1, 1)
    for i, v in pairs(map.rooms) do
        love.graphics.rectangle("line", v.x-camera_x, v.y-camera_y, v.w, v.h)
        icon_x = (v.x + v.w / 3) - camera_x
        icon_y = v.y + 3 - camera_y
        if v.isVisible then
          love.graphics.draw(icons[v.type], icon_x, icon_y, 0, 0.05, 0.05)
          if v.warning then
            love.graphics.draw(icons[v.warning], icon_x, icon_y, 0, 0.05, 0.05)
          end
        end
    end

    -- map.DOORS
    love.graphics.setColor(1, 0, 0)
    for i, v in pairs(map.doors) do
        -- position the doors between the rooms midpoints
        local x = ((map.rooms[v.room1].x + map.rooms[v.room1].w / 2) + (map.rooms[v.room2].x + map.rooms[v.room2].w / 2)) / 2
        local y = ((map.rooms[v.room1].y + map.rooms[v.room1].h / 2) + (map.rooms[v.room2].y + map.rooms[v.room2].h / 2)) / 2
        local mode = "fill"
        if v.isOpen then
            mode = "line"
        end
        love.graphics.rectangle(mode, x-camera_x, y-camera_y, 10, 10)
    end

    -- PEOPLE
    love.graphics.setColor(1, 1, 1)
    for i, v in pairs(people) do
      local x = map.rooms[people[i].room].x
      local y = map.rooms[people[i].room].y
        love.graphics.rectangle("fill", x-camera_x, y-camera_y, 10, 10)
    end

    -- UI
    love.graphics.setColor(1, 1, 1)
    for i, v in pairs(people) do
        love.graphics.draw(icons.person, 600, 50 * i, 0, 0.06, 0.06)
        love.graphics.print("[" .. i .. "] - " .. v.name, 630, 50 * i)
    end

    -- TEXTBOX
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", textbox.x, textbox.y, textbox.w, textbox.h)

    -- CHAT
    love.graphics.setColor(1, 1, 1)
    for i, v in pairs(sentences) do
      love.graphics.print(v, textbox.x, textbox.y + ((i - 1) * 15))
    end
end

function love.update(dt)
  -- UPDATE CAMERA
  time = time + dt

  local ydiff = 0
  local xdiff = 0
  if keys.w then
    ydiff = ydiff - 1
  end

  if keys.s then
    ydiff = ydiff + 1
  end

  if keys.a then
    xdiff = xdiff - 1
  end

  if keys.d then
    xdiff = xdiff + 1
  end

  local camSpeed = 5
  camera_x = camera_x + xdiff * camSpeed
  camera_y = camera_y + ydiff * camSpeed

  -- UPDATE PEOPLE
  for i, v in pairs(people) do
    updatePerson(v, dt)
  end
end

function love.keyreleased(key)
    if key == "return" then
        openDoor(people[1], 1)
    elseif key == "space" then
        moveRoom(people[1], 2)
    end

    keys[key] = false
end

function love.keypressed(key)
  keys[key] = true
end

function love.load()
    math.randomseed(os.time())

    for i = 1, 5 do
        table.insert(sentences, i, "this is a sentence" .. i)
    end

    table.insert(people, createPerson("Emily", 50, 50))
    table.insert(people, createPerson("David", 50, 50))

    -- create map
    map.randomWalk(50)

    icons["bridge"] = love.graphics.newImage("img/radar-sweep-glow.png")
    icons["weapons"] = love.graphics.newImage("img/heavy-bullets-glow.png")
    icons["cryo"] = love.graphics.newImage("img/cryo-chamber-glow.png")
    icons["engines"] = love.graphics.newImage("img/rocket-thruster-glow.png")
    icons["person"] = love.graphics.newImage("img/person-glow.png")
    icons["hazard"] = love.graphics.newImage("img/hazard-sign.png")
    icons["radioactive"] = love.graphics.newImage("img/radioactive.png")
end
