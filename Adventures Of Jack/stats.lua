-- stats.luaI 
local Stats = {}

Stats.playerStats = {
    health = 100,
    attack = 10,
    defense = 10,
    speed = 50,
    stamina = 100,
    maxStamina = 100,
    sprintDuration = 0.5, 
    staminaRechargeRate = .1,  
    currentStamina = 100,
    isSprinting = false,
    sprintTimer = 0,
    rechargeTimer = 0
}


Stats.robotStats = {
    health = 50,
    attack = 5,
    defense = 10,
    stamina = 100,
    speed = 1
    
}

Stats.rootyStats = {
    health = 10,
    attack = 10,
    defense = 10,
    stamina = 10,
    speed = 0
}

Stats.flashyStats = {
    health = 10,
    attack = 10,
    defense = 10,
    stamina = 10,
    speed = 10
}

Stats.truckStats = {
    health = 1000,
    attack = 100,
    defense = 100,
    stamina = 100,
    speed = 50
}


function Stats.updatePlayerStamina(dt)
    local player = Stats.playerStats
    if player.isSprinting then
        player.sprintTimer = player.sprintTimer + dt
        local staminaCost = dt / player.sprintDuration  
        player.currentStamina = math.max(0, player.currentStamina - staminaCost)

        if player.currentStamina <= 0 then
            player.isSprinting = false  
            player.currentStamina = 0
        end
    else
        player.rechargeTimer = player.rechargeTimer + dt
        if player.rechargeTimer >= player.staminaRechargeRate then
            player.currentStamina = math.min(player.maxStamina, player.currentStamina + 1)
            player.rechargeTimer = 0
        end
    end
end

function Stats.startSprinting()
    local player = Stats.playerStats
    if player.currentStamina > 0 then
        player.isSprinting = true
        player.sprintTimer = 0
    end
end

function Stats.stopSprinting()
    Stats.playerStats.isSprinting = false
    Stats.playerStats.sprintTimer = 0
end



function Stats.getPlayerStats()
    return Stats.playerStats
end

function Stats.getRobotStats()
    return Stats.robotStats
end

function Stats.getRootyStats()
    return Stats.rootyStats
end

function Stats.getFlashyStats()
    return Stats.flashyStats
end

function Stats.getTruckStats()
    return Stats.truckStats
end

return Stats

