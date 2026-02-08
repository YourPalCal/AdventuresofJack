--Adventures of Jack-- Jack.CEO?
--main.lua
--By Cal--

local sti 
local gameMap
local camera 
local Stats = require 'stats'
local Entities = require 'entities'
local Pause = require 'pause'
local Stats = require 'stats'



function love.load()
    love.window.setMode(1280, 720)
    love.graphics.setDefaultFilter("nearest", "nearest")
    wf = require 'lib/windfield'
    world = wf.newWorld(0, 0)    
    anim8 = require 'lib/anim8'
    sti = require 'lib/sti'
    gameMap = sti('assets/maps/mainmap.lua')
    camera = require 'lib/camera'
    cam = camera()
   
    sounds = {}
    sounds.music = love.audio.newSource("assets/sounds/Pixel_Dreams.mp3", "stream")
    sounds.music:setLooping(true)

    world:addCollisionClass("Player")
    world:addCollisionClass("Entity")
    world:addCollisionClass("Wall")
   
    player = Entities.loadPlayer(world, Stats)
    robot = Entities.loadRobot(world, Stats)
    rooty = Entities.loadRooty(world, Stats)
    flashy = Entities.loadFlashy(world, Stats)
    truck = Entities.loadTruck(world, Stats)
   
    walls = Entities.loadWalls(world, gameMap)
   
    sounds.music:play()
    Pause.load()
end

function love.update(dt)
    if not Pause.isPaused then
        Stats.updatePlayerStamina(dt)
        Entities.updatePlayer(player, dt)
        Entities.updateRobot(robot, dt)
        Entities.updateRooty(rooty, dt)
        Entities.updateFlashy(flashy, dt)
        Entities.updateTruck(truck, dt)
        
        world:update(dt)
        gameMap:update(dt)
        cam:lookAt(player.x * 4, player.y * 4)
    end
end

function love.draw()
    cam:attach()
        love.graphics.scale(4)
        gameMap:drawLayer(gameMap.layers["ground"])

        Entities.drawRobot(robot)
        Entities.drawRooty(rooty)
        Entities.drawFlashy(flashy)
        Entities.drawTruck(truck)
        Entities.drawPlayer(player)
        --world:draw()
    cam:detach()
   
    if Pause.isPaused then
        Pause.draw()
    end
end

function love.keypressed(key)
    if key == "escape" then
        Pause.toggle()
    end
end
