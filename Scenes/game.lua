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
    love.graphics.draw(road.image, road.x, road.v1y) -- Draws the road sprites
    love.graphics.draw(road.image, road.x, road.v2y)
    love.graphics.draw(carSprite.image, carSprite.x, carSprite.y, carSprite.rotation, carSprite.scaleX, carSprite.scaleY) -- Draws the car sprite
end

function loadCar()
    carSprite = love.graphics.newImage("Sprites/yellowcar.png")
    carSprite = loadObject(objectName, ((screenWidth/2)), 1000, (-math.pi/2), 1, 1, 30, "Sprites/yellowcar.png", 60, 30)
end

function loadObject(objectName, x, y, rotation, scaleX, scaleY, health, image, width, height)
    local object = {
        x = x,
        y = y,
        rotation = rotation,
        scaleX = scaleX,
        scaleY = scaleY,
        speed = 0,
        accel = 250,
        rotationSpeed = 0,
        width = width,
        height = height,
        image = love.graphics.newImage(image)
    }
    return object
end

function playerUpdate(dt)
    if love.keyboard.isDown('right') then -- Turning
        carSprite.x = carSprite.x + carSprite.accel * dt
    elseif love.keyboard.isDown('left') then
        carSprite.x = carSprite.x - carSprite.accel * dt
    end
    if love.keyboard.isDown('up') then -- Moving
        backgroundSpeed = backgroundSpeed - carSprite.accel * dt
    elseif love.keyboard.isDown('down') then
        backgroundSpeed = backgroundSpeed + carSprite.accel * dt
    end
end

function loadRoad()
    image = love.graphics.newImage("Sprites/road.png")

    road = {
        image = image, -- Art pass comes later ..
        x = ((screenWidth/2)-(image:getWidth()/2)),
        v2x = 0,
        v1y = 0,
        v2y = image:getHeight(),
    }
end

function roadUpdate(dt)
    road.v1y = road.v1y - backgroundSpeed * dt
    road.v2y = road.v2y - backgroundSpeed * dt

    if backgroundSpeed > 0 then
        if road.v1y < -road.image:getHeight() then
            road.v1y = road.v2y + road.image:getHeight()
        end

        if road.v2y < -road.image:getHeight() then
            road.v2y = road.v1y + road.image:getHeight()
        end

    elseif backgroundSpeed < 0 then
        if road.v1y > road.image:getHeight() then
            road.v1y = road.v2y - road.image:getHeight()
        end

        if road.v2y > road.image:getHeight() then
            road.v2y = road.v1y - road.image:getHeight()
        end
    end
end


return arcadeGame