radio = require "radio"
local map = require "map"
local personMenu = require"person_menu"

keys = {
  w = false,
  a = false,
  s = false,
  d = false
}

updateStep = 1000 / 60

textbox = {
    x = 10,
    y = 300,
    w = 500,
    h = 5 * 15
}

icons = {}

gameModes = {
  MAP = 1,
  PERSON_MENU = 2
}

items = {
  plasmaCutter = "Plasma Cutter",
  doorInterface = "Door Interface",
  roomInterface = "Room Interface",
  oxygenTank = "Oxygen Tank",
  t1Scanner = "T1 Scanner",
  t1PowerSource = "T1 Power Source"
}

local gameState = {
  sentences = {},
  gameMode = 1,
  time = 0,
  camera_x = 0,
  camera_y = 0,
  map = map,
  people = {},
  currentMenu = nil
}

function getIconQuad(x, y, w, h, image)
  icon_quad = love.graphics.newQuad(x, y, w, h, image:getWidth(), image:getHeight())
end

function createPerson(name, x, y)
  return {
    items = {},
    name = name,
    stressLevel = 0,
    x = x,
    y = y,
    lastUpdated = 0,
    room = 1,
    state = nil
  }
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
    table.remove(gameState.sentences, 1)
end

function speak(name, text)
    if table.getn(gameState.sentences) > 4 then
        table.remove(gameState.sentences, 1)
    end

    table.insert(gameState.sentences, name .. ": " .. text)
end

function love.draw()

    -- ROOMS
    love.graphics.setColor(1, 1, 1)
    for i, v in pairs(gameState.map.rooms) do

      if v.isVisible then
        love.graphics.rectangle("line", v.x-gameState.camera_x, v.y-gameState.camera_y, v.w, v.h)
        icon_x = (v.x + v.w / 3) - gameState.camera_x
        icon_y = v.y + 3 - gameState.camera_y
        love.graphics.draw(icons[v.type], icon_x, icon_y, 0, 0.05, 0.05)
          if v.warning then
            love.graphics.draw(icons[v.warning], icon_x, icon_y, 0, 0.05, 0.05)
          end
        end
    end

    -- map.DOORS
    love.graphics.setColor(1, 0, 0)
    for i, v in pairs(gameState.map.doors) do
      if gameState.map.rooms[v.room1].isVisible or gameState.map.rooms[v.room2].isVisible then
        -- position the doors between the rooms midpoints
        local x = ((gameState.map.rooms[v.room1].x + gameState.map.rooms[v.room1].w / 2) + (gameState.map.rooms[v.room2].x + gameState.map.rooms[v.room2].w / 2)) / 2
        local y = ((gameState.map.rooms[v.room1].y + gameState.map.rooms[v.room1].h / 2) + (gameState.map.rooms[v.room2].y + gameState.map.rooms[v.room2].h / 2)) / 2
        local mode = "fill"
        if v.isOpen then
          mode = "line"
        end
        love.graphics.rectangle(mode, x-gameState.camera_x, y-gameState.camera_y, 10, 10)
      end
    end

    -- PEOPLE
    love.graphics.setColor(1, 1, 1)
    for i, v in pairs(gameState.people) do
      local x = gameState.map.rooms[gameState.people[i].room].x
      local y = gameState.map.rooms[gameState.people[i].room].y
        love.graphics.rectangle("fill", x-gameState.camera_x, y-gameState.camera_y, 10, 10)
    end

    -- UI
    love.graphics.setColor(1, 1, 1)
    for i, v in pairs(gameState.people) do
        love.graphics.draw(icons.person, 600, 50 * i, 0, 0.06, 0.06)
        love.graphics.print("[" .. i .. "] - " .. v.name, 630, 50 * i)
    end

    -- TEXTBOX
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", textbox.x, textbox.y, textbox.w, textbox.h)

    -- CHAT
    love.graphics.setColor(1, 1, 1)
    for i, v in pairs(gameState.sentences) do
      love.graphics.print(v, textbox.x, textbox.y + ((i - 1) * 15))
    end

    if gameState.gameMode == gameModes.PERSON_MENU and gameState.currentMenu ~= nil then
      personMenu.renderMenu(gameState.currentMenu)
    end
end

function love.update(dt)

  -- UPDATE CAMERA
  gameState.time = gameState.time + dt

  if gameState.gameMode == gameModes.MAP then
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

    if keys.m then
      gameState.gameMode = gameModes.PERSON_MENU
      gameState.currentMenu = personMenu.personMenu(gameState, 1)
    end

    local camSpeed = 5
    gameState.camera_x = gameState.camera_x + xdiff * camSpeed
    gameState.camera_y = gameState.camera_y + ydiff * camSpeed

  elseif gameState.gameMode == gameModes.PERSON_MENU then
    if keys["return"] then
      keys["return"] = false
      gameState.currentMenu.options[gameState.currentMenu.selected]()

    end

    if keys["up"] then
      keys["up"] = false
      personMenu.selectPreviousOption(gameState.currentMenu)
    end

    if keys["down"] then
      keys["down"] = false
      personMenu.selectNextOption(gameState.currentMenu)
    end
  end

  -- UPDATE PEOPLE
  for i, v in pairs(gameState.people) do
    updatePerson(v, dt)
  end
end

function love.keyreleased(key)
    keys[key] = false
end

function love.keypressed(key)
  keys[key] = true
end

function love.load()
    math.randomseed(os.time())

    for i = 1, 5 do
        table.insert(gameState.sentences, i, "this is a sentence" .. i)
    end

    table.insert(gameState.people, createPerson("Emily", 50, 50))
    table.insert(gameState.people, createPerson("David", 50, 50))

    table.insert(gameState.people[1].items, items.plasmaCutter)
    table.insert(gameState.people[1].items, items.t1Scanner)
    table.insert(gameState.people[2].items, items.t1PowerSource)

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
