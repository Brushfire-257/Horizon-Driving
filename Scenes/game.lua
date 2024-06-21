-- The arcade loop for the game.

-- Scene container
arcadeGame = {}

-- misc. setup
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local timer = 0

local backgroundSpeed = 0

-- Library(s)
HC = require 'HardonCollider'

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

    -- Load Game settings (currently just debug mode)
    local settingsStr = love.filesystem.read("settings.txt")
    loadSettings(settingsStr)
end

function arcadeGame.update(dt) -- Runs every frame.
    playerUpdate(dt)

    roadUpdate(dt)
end

function arcadeGame.draw() -- Draws every frame / Runs directly after love.update()
    love.graphics.draw(road.image, road.x, road.v1y) -- Draws the road sprites
    love.graphics.draw(road.image, road.x, road.v2y)

    love.graphics.draw(carSprite.image, carSprite.x, carSprite.y,
    carSprite.rotation, carSprite.scaleX, carSprite.scaleY,
    carSprite.rotationX, carSprite.rotationY) -- Draws the car sprite

    -- Draw the edges of car collider
    if debugMode then
        love.graphics.setColor(1, 0, 0) -- Set the color to red
        local points = {carCollider._polygon:unpack()}
        for i = 1, #points, 2 do
            local next_i = i + 2
            if next_i > #points then next_i = 1 end
            love.graphics.line(points[i], points[i+1], points[next_i], points[next_i+1])
        end
        love.graphics.setColor(1, 1, 1) -- Reset the color to white
    end
end

function loadCar()
    scaleX = 0.5
    scaleY = 0.5
    image = love.graphics.newImage("Sprites/yellowcar.png")
    carSprite = loadObject("playerCar", ((screenWidth/2)), 1000, (-math.pi/2), scaleX, scaleY, 30, "Sprites/yellowcar.png",
    (image:getWidth()*scaleX), (image:getHeight()*scaleY), (image:getWidth()/2), (image:getHeight()/2))
    
    --polygon collider for the car
    carCollider = HC.polygon(
        carSprite.x, carSprite.y,
        carSprite.x + carSprite.width, carSprite.y,
        carSprite.x + carSprite.width, carSprite.y + carSprite.height,
        carSprite.x, carSprite.y + carSprite.height
    )
end

function loadObject(objectName, x, y, rotation, scaleX, scaleY, health, image, width, height, rotationX, rotationY)
    local object = {
        x = x,
        y = y,
        rotation = rotation,
        rotationX = rotationX,
        rotationY = rotationY,
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
    if love.keyboard.isDown(',') then -- Rotation (Testing)
        carSprite.rotation = carSprite.rotation - (math.pi/4) * dt
    elseif love.keyboard.isDown('.') then
        carSprite.rotation = carSprite.rotation + (math.pi/4) * dt
    end
    if love.keyboard.isDown('up') then -- Moving
        backgroundSpeed = backgroundSpeed - carSprite.accel * dt
    elseif love.keyboard.isDown('down') then
        backgroundSpeed = backgroundSpeed + carSprite.accel * dt
    end

    -- Update collider position and rotation
    carCollider:moveTo(carSprite.x, carSprite.y)
    carCollider:rotate(carSprite.rotation - carCollider:rotation(), carCollider:center())
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

function loadSettings(settingsStr)
    for line in settingsStr:gmatch("[^\r\n]+") do
        local key, value = line:match("(%w+)%s*=%s*(%w+)")
        if key and value then
            if key == "debugMode" then
                debugMode = tonumber(value) == 1
            end
            -- Add more settings here...
        end
    end
end

return arcadeGame