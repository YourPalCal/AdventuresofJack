--pause.lua

local Pause = {}

Pause.isPaused = false
local jackImage
local jackQuads = {}
local currentFrame = 1
local animationTimer = 0
local textboxImage


function Pause.load()
    jackImage = love.graphics.newImage("assets/sprites/jack.png")
    textboxImage = love.graphics.newImage("assets/sprites/textbox.png")
    local frameWidth = jackImage:getWidth() / 2
    local frameHeight = jackImage:getHeight()
    jackQuads[1] = love.graphics.newQuad(0, 0, frameWidth, frameHeight, jackImage:getDimensions())
    jackQuads[2] = love.graphics.newQuad(frameWidth, 0, frameWidth, frameHeight, jackImage:getDimensions())
end

function Pause.toggle()
    Pause.isPaused = not Pause.isPaused
    animationTimer = 0
    currentFrame = 1
end

function Pause.update(dt)
    if Pause.isPaused then
        animationTimer = animationTimer + dt
        if animationTimer >= 4 then
            currentFrame = currentFrame == 1 and 2 or 1
            animationTimer = animationTimer - 4
        end
    end
end

function Pause.draw()
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", w * 0.05, h * 0.05, w * 0.9, h * 0.9)
    
    if textboxImage then
        local scale = 4
        local textboxWidth = textboxImage:getWidth() * scale
        local textboxHeight = textboxImage:getHeight() * scale
        love.graphics.draw(textboxImage, w / 2 - textboxWidth / 2, h / 2 - textboxHeight / 2, 0, scale, scale)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("PAUSED", w / 2 - 30, h / 2 - 60)
    
    if jackImage then
        love.graphics.draw(jackImage, jackQuads[currentFrame], w * 0.07, h * 0.416, 0, 6, 6)
    end
    

end

return Pause