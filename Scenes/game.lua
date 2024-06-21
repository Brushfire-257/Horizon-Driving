-- The arcade loop for the game.

-- To Do List:
-- Make a to do list

-- Scene container
arcadeGame = {}

-- misc. setup
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local timer = 0

local backgroundSpeed = 0

function arcadeGame.load() -- Runs once at the start of the game.
    -- Load window values
    love.window.setMode(1280, 720) -- Set to 1920 x 1080 on launch
    love.window.setTitle("Horizon Driving - Arcade Mode")
    love.window.setFullscreen(true)

    -- Reseed RNG
    love.math.setRandomSeed(os.time())

    -- Load the player car
    loadCar()
    loadRoad()
end

function arcadeGame.update(dt) -- Runs every frame.
    playerUpdate(dt)

    roadUpdate(dt)
end

function arcadeGame.draw() -- Draws every frame / Runs directly after love.update()
    love.graphics.draw(background1, 0, background1Y) -- Draws the road sprites
    love.graphics.draw(background2, 0, background2Y)
    love.graphics.draw(carSprite.image, carSprite.x, carSprite.y, carSprite.rotation, carSprite.scaleX, carSprite.scaleY) -- Draws the car sprite
end

function loadCar()
    carSprite = love.graphics.newImage("Sprites/yellowcar.png")
    carSprite = loadObject(objectName, 0, 1000, (-math.pi/2), 1, 1, 30, "Sprites/yellowcar.png")
end

function loadObject(objectName, x, y, rotation, scaleX, scaleY, health, image)
    local object = {
        x = x,
        y = y,
        rotation = rotation,
        scaleX = scaleX,
        scaleY = scaleY,
        velocityX = 0,
        velocityY = 0,
        speed = 0,
        accel = 50,
        rotationSpeed = 0,
        radius = 15,
        image = love.graphics.newImage(image)
    }
    return object
end

function playerUpdate(dt)
    if love.keyboard.isDown('right') then
        carSprite.x = carSprite.x + carSprite.accel * dt
    elseif love.keyboard.isDown('left') then
        carSprite.x = carSprite.x - carSprite.accel * dt
    elseif love.keyboard.isDown('up') then
        backgroundSpeed = backgroundSpeed - carSprite.accel * dt
    elseif love.keyboard.isDown('down') then
        backgroundSpeed = backgroundSpeed + carSprite.accel * dt
    end
end

function loadRoad()
    background1 = love.graphics.newImage("Sprites/road.png") -- Art pass comes later ..
    background2 = love.graphics.newImage("Sprites/road.png")
    background1Y = 0
    background2Y = background1:getHeight()
end

function roadUpdate(dt)
    background1Y = background1Y - backgroundSpeed * dt
    background2Y = background2Y - backgroundSpeed * dt

    if backgroundSpeed < 0 then
        if background1Y < -background1:getHeight() then
            background1Y = background2Y + background2:getHeight()
        end

        if background2Y < -background2:getHeight() then
            background2Y = background1Y + background1:getHeight()
        end

    elseif backgroundSpeed > 0 then
        if background1Y > background1:getHeight() then
            background1Y = background2Y - background2:getHeight()
        end

        if background2Y > background2:getHeight() then
            background2Y = background1Y - background1:getHeight()
        end
    end
end


return arcadeGame