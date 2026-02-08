--entities.lua--
--By Cal--


local Entities = {}

-------------------------------------------------------------------------------------------
--PLAYER-----------------------------------------------------------------------------------

function Entities.loadPlayer(world, Stats)
    local player = {}
    player.stats = Stats.getPlayerStats()
    player.collider = world:newBSGRectangleCollider(70, 15, 10, 10, 1)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass("Player") 
    player.spriteSheet = love.graphics.newImage("assets/sprites/player-sheet.png")
    player.idleSpriteSheet = love.graphics.newImage("assets/sprites/jack-talk.png")
    player.twerkSpriteSheet = love.graphics.newImage("assets/sprites/jack-twerk.png")
    player.smokeSpriteSheet = love.graphics.newImage("assets/particles/smoke.png")
    player.y = 15
    player.speed = player.stats.speed 
    player.grid = anim8.newGrid(32, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.idleGrid = anim8.newGrid(32, 32, player.idleSpriteSheet:getWidth(), player.idleSpriteSheet:getHeight())
    player.twerkGrid = anim8.newGrid(32, 32, player.twerkSpriteSheet:getWidth(), player.twerkSpriteSheet:getHeight())
    player.smokeGrid = anim8.newGrid(128, 128, player.smokeSpriteSheet:getWidth(), player.smokeSpriteSheet:getHeight())
    player.width = 32 
    player.height = 32
    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2) 
    player.animations.right = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    player.animations.idle = anim8.newAnimation(player.idleGrid('1-4', 1, '1-4', 2), 0.2)
    player.animations.twerk = anim8.newAnimation(player.twerkGrid('1-3', 1, '1-3', 2, '1-1', 3), 0.1)
    player.animations.smoke = anim8.newAnimation(player.smokeGrid('1-4', 1, '1-4', 2, '1-2', 3), 0.1)
    player.anim = player.animations.idle 
    player.isFarting = false

    return player
end

function Entities.updatePlayer(player, dt)
    local isMoving = false 
    local vy = 0
    local vx = 0


    local sprinting = love.keyboard.isDown("lshift") and player.stats.currentStamina > 0
    local speed = sprinting and 100 or player.speed 

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        vy = speed * -1 
        player.anim = player.animations.up
        isMoving = true
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        vy = speed  
        player.anim = player.animations.down
        isMoving = true
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        vx = speed * -1  
        player.anim = player.animations.left
        isMoving = true
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        vx = speed  
        player.anim = player.animations.right
        isMoving = true
    end

    if sprinting then
        player.stats.isSprinting = true
    else
        player.stats.isSprinting = false
    end

    if love.keyboard.isDown("space") then
        player.isFarting = true
        player.anim = player.animations.twerk
        player.animations.smoke:update(dt)
    else
        player.isFarting = false
    end

    if not isMoving and not player.isFarting then
        player.anim = player.animations.idle
    end

    player.collider:setLinearVelocity(vx, vy)
    player.anim:update(dt)

    player.x = player.collider:getX()
    player.y = player.collider:getY()
end

function Entities.drawPlayer(player)
    if player.isFarting then
        player.animations.twerk:draw(player.twerkSpriteSheet, player.x - 8, player.y - 13, nil, .55)
        player.animations.smoke:draw(player.smokeSpriteSheet, player.x - 32, player.y - 32, nil, .55)
    elseif player.anim == player.animations.idle then
        player.anim:draw(player.idleSpriteSheet, player.x - 8, player.y - 13, nil, .55)
    else
        player.anim:draw(player.spriteSheet, player.x - 8, player.y - 13, nil, .55)
    end

    
    local x, y = player.x, player.y - 50  
    local staminaWidth = 100 * (player.stats.currentStamina / player.stats.maxStamina)
    love.graphics.setColor(1, 1, 0) 
    love.graphics.rectangle("fill", x - 155, y + 130, staminaWidth, 10) 
    love.graphics.setColor(1, 1, 1) 

    local xPos = player.x  --this section lets you see your player x,y position
    local yPos = player.y
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X: " .. math.floor(xPos) .. " Y: " .. math.floor(yPos), player.x - player.width / 1.5, player.y - player.height - 10)

end

-------------------------------------------------------------------------------------------
--ROBOT------------------------------------------------------------------------------------

function Entities.loadRobot(world, Stats)
    local robot = {}
    robot.stats = Stats.getRobotStats()
    robot.spriteSheet = love.graphics.newImage("assets/sprites/robot.png")
    robot.grid = anim8.newGrid(32, 32, robot.spriteSheet:getWidth(), robot.spriteSheet:getHeight())
    robot.animations = {}
    robot.animations.down = anim8.newAnimation(robot.grid('1-1', 1), 0.2) 
    robot.animations.right = anim8.newAnimation(robot.grid('2-2', 1), 0.2)
    robot.animations.left = anim8.newAnimation(robot.grid('1-1', 2), 0.2) 
    robot.animations.up = anim8.newAnimation(robot.grid('2-2', 2), 0.2)
    robot.animations.idle = anim8.newAnimation(robot.grid('1-1', 1), 0.2) 
    robot.anim = robot.animations.idle
    robot.x = 350
    robot.y = 700
    robot.speed = robot.stats.speed

    robot.collider = world:newBSGRectangleCollider(robot.x, robot.y, 22, 22, 1)
    robot.collider:setFixedRotation(true)
    robot.collider:setType('dynamic')
    robot.collider:setCollisionClass("Entity")

    return robot
end

function Entities.updateRobot(robot, dt)
    local robotMoveRange = 10
    if not robot.targetX or not robot.targetY or math.random() < 0.01 then 
        robot.targetX = robot.x + math.random(-robotMoveRange, robotMoveRange)
        robot.targetY = robot.y + math.random(-robotMoveRange, robotMoveRange)
    end

    local robotSpeed = robot.speed
    local dx = robot.targetX - robot.x
    local dy = robot.targetY - robot.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 1 then
        robot.x = robot.x + (dx / distance) * robotSpeed * dt
        robot.y = robot.y + (dy / distance) * robotSpeed * dt
        robot.collider:setPosition(robot.x, robot.y)

        if math.abs(dx) > math.abs(dy) then
            if dx > 0 then
                robot.anim = robot.animations.right
            else
                robot.anim = robot.animations.left
            end
        else
            if dy > 0 then
                robot.anim = robot.animations.down
            else
                robot.anim = robot.animations.up
            end
        end
    else
        robot.anim = robot.animations.idle
    end

    robot.collider:setPosition(robot.x, robot.y)
    robot.anim:update(dt)
end

function Entities.drawRobot(robot)
    robot.anim:draw(robot.spriteSheet, robot.x - 15, robot.y - 15, nil, .9)
end

-------------------------------------------------------------------------------------------
--ROOTY------------------------------------------------------------------------------------

function Entities.loadRooty(world, Stats)
    local rooty = {}
    rooty.stats = Stats.getRootyStats()
    rooty.spriteSheet = love.graphics.newImage('assets/sprites/rooty.png')
    rooty.grid = anim8.newGrid(32, 32, rooty.spriteSheet:getWidth(), rooty.spriteSheet:getHeight())
    rooty.animations = {}
    rooty.animations.cycle = anim8.newAnimation(rooty.grid('1-2', 1, '1-1', 2), 1)
    rooty.x = 1200
    rooty.y = 480
    rooty.speed = rooty.stats.speed

    rooty.collider = world:newBSGRectangleCollider(rooty.x, rooty.y, 10, 12, 1)
    rooty.collider:setFixedRotation(true)
    rooty.collider:setType('static')
    rooty.collider:setCollisionClass("Entity")

    return rooty
end

function Entities.updateRooty(rooty, dt)
    rooty.animations.cycle:update(dt)
end

function Entities.drawRooty(rooty)
    rooty.animations.cycle:draw(rooty.spriteSheet, rooty.x - 4, rooty.y - 2, nil, .5)
end

-------------------------------------------------------------------------------------------
--FLASHY-----------------------------------------------------------------------------------

function Entities.loadFlashy(world, Stats)
    local flashy = {}
    flashy.stats = Stats.getFlashyStats()
    flashy.spriteSheet = love.graphics.newImage('assets/sprites/blinky.png')
    flashy.grid = anim8.newGrid(32, 32, flashy.spriteSheet:getWidth(), flashy.spriteSheet:getHeight())
    flashy.animations = {}
    flashy.animations.cycle = anim8.newAnimation(flashy.grid('1-2', 1, '1-2', 2), 0.1)
    flashy.x = 950
    flashy.y = 50
    flashy.speed = flashy.stats.speed
    flashy.minX = 950
    flashy.maxX = 1300 
    flashy.direction = 1 
    flashy.collider = world:newBSGRectangleCollider(flashy.x, flashy.y, 25, 24, 1)
    flashy.collider:setFixedRotation(true)
    flashy.collider:setType('dynamic')
    flashy.collider:setCollisionClass("Entity")
    
    return flashy
end



function Entities.updateFlashy(flashy, dt)
    flashy.animations.cycle:update(dt)
    flashy.x = flashy.x + flashy.speed * flashy.direction * dt
    if flashy.x >= flashy.maxX then
        flashy.direction = -1
    elseif flashy.x <= flashy.minX then
        flashy.direction = 1
    end
    
    flashy.collider:setPosition(flashy.x, flashy.y)
end

function Entities.drawFlashy(flashy)
    flashy.animations.cycle:draw(flashy.spriteSheet, flashy.x - 14, flashy.y - 13, nil, 1)
end

-------------------------------------------------------------------------------------------
--Truck------------------------------------------------------------------------------------

function Entities.loadTruck(world, Stats)
    local truck = {}
    truck.stats = Stats.getTruckStats()
    truck.spriteSheet = love.graphics.newImage('assets/sprites/pepsi-truck.png')
    truck.grid = anim8.newGrid(128, 108, truck.spriteSheet:getWidth(), truck.spriteSheet:getHeight())
    truck.animations = {}
    truck.animations.left = anim8.newAnimation(truck.grid('1-3', 1), 0.1)
    truck.animations.right = anim8.newAnimation(truck.grid('1-3', 2), 0.1)
    truck.x = 75
    truck.y = 198
    truck.speed = truck.stats.speed
    truck.minX = 75
    truck.maxX = 600 
    truck.direction = 1
    truck.collider = world:newBSGRectangleCollider(truck.x, truck.y, 87, 40, 1)
    truck.collider:setFixedRotation(true)
    truck.collider:setType('dynamic')
    truck.collider:setCollisionClass("Entity")
    
    return truck
end



function Entities.updateTruck(truck, dt)
    truck.animations.left:update(dt)
    truck.animations.right:update(dt)
    truck.x = truck.x + truck.speed * truck.direction * dt
    if truck.x >= truck.maxX then
        truck.direction = -1
    elseif truck.x <= truck.minX then
        truck.direction = 1
    end
    
    truck.collider:setPosition(truck.x, truck.y)
end

function Entities.drawTruck(truck)
    local anim = truck.direction == 1 and truck.animations.right or truck.animations.left
    anim:draw(truck.spriteSheet, truck.x - 64, truck.y - 50, nil, 1)
end



-------------------------------------------------------------------------------------------
--WALLS------------------------------------------------------------------------------------

function Entities.loadWalls(world, gameMap)
    local walls = {}
    if gameMap.layers["walls"] then
        for i, obj in pairs(gameMap.layers["walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            wall:setCollisionClass("Wall")
            table.insert(walls, wall)
        end
    end
    return walls
end

return Entities