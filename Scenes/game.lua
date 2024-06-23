-- The arcade loop for the game.

-- Scene container
arcadeGame = {}

-- misc. setup
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local timer = 0
local colliders = {}

local backgroundSpeed = 0

-- Libraries
HC = require 'HardonCollider'
local Camera = require 'hump.camera'

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
    loadTraffic()
    loadPolice()

    -- Create camera
    camerayOffset = 400
    camerayShake = 0
    camera = Camera(carSprite.x, carSprite.y - camerayOffset)

    -- Load Game settings (currently just debug mode)
    local settingsStr = love.filesystem.read("settings.txt")
    loadSettings(settingsStr)
end

function arcadeGame.update(dt) -- Runs every frame.
    colliders = {} -- clear the table for new values

    playerUpdate(dt)
    roadUpdate(dt)
    updateTraffic(dt)
    updatePolice(dt)
end

function arcadeGame.draw() -- Draws every frame / Runs directly after love.update()
    camera:attach()
    love.graphics.draw(road.image, road.x, road.v1y, 0, road.scaleX, road.scaleY) -- Draws the road sprites
    love.graphics.draw(road.image, road.x, road.v2y, 0, road.scaleX, road.scaleY)

    love.graphics.draw(trafficRight.image, trafficRight.x, trafficRight.y, trafficRight.rotation, trafficRight.scaleX, trafficRight.scaleY,
    trafficRight.rotationX, trafficRight.rotationY)
    love.graphics.draw(trafficLeft.image, trafficLeft.x, trafficLeft.y, trafficLeft.rotation, trafficLeft.scaleX, trafficLeft.scaleY,
    trafficLeft.rotationX, trafficLeft.rotationY)

    love.graphics.draw(policeSprite.image, policeSprite.x, policeSprite.y, policeSprite.rotation, policeSprite.scaleX, policeSprite.scaleY,
    policeSprite.rotationX, policeSprite.rotationY)

    love.graphics.draw(carSprite.image, carSprite.x, carSprite.y, carSprite.rotation, carSprite.scaleX, carSprite.scaleY,
        carSprite.rotationX, carSprite.rotationY) -- Draws the car sprite

    -- Draw the edges of car collider
    if debugMode then
        love.graphics.setColor(1, 0, 0) -- Set the color to red
        for _, collider in ipairs(colliders) do
            local points = {collider._polygon:unpack()}
            for i = 1, #points, 2 do
                local next_i = i + 2
                if next_i > #points then next_i = 1 end
                love.graphics.line(points[i], points[i+1], points[next_i], points[next_i+1])
            end
        end
        love.graphics.setColor(1, 1, 1) -- Reset the color to white
    end
    camera:detach()
end

function loadCar()
    local scaleX = 0.5
    local scaleY = 0.5
    image = love.graphics.newImage("Sprites/yellowcar.png")
    carSprite = loadObject("playerCar", ((screenWidth / 2)), 1000, (-math.pi / 2), scaleX, scaleY, 30, "Sprites/yellowcar.png",
        (image:getWidth() * scaleX), (image:getHeight() * scaleY), (image:getWidth() / 2), (image:getHeight() / 2))
    carSprite.prevX = 1000
    carSprite.prevY = 800

    -- polygon collider for the car
    carCollider = HC.polygon(
        carSprite.x, carSprite.y,
        carSprite.x + carSprite.width, carSprite.y,
        carSprite.x + carSprite.width, carSprite.y + carSprite.height,
        carSprite.x, carSprite.y + carSprite.height
    )
    table.insert(colliders, carCollider)
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
        accel = 600,
        rotationSpeed = 2,
        width = width,
        height = height,
        image = love.graphics.newImage(image)
    }
    return object
end

function playerUpdate(dt)
    if love.keyboard.isDown('right') then -- Turning
        carSprite.rotation = carSprite.rotation + carSprite.rotationSpeed * dt
    elseif love.keyboard.isDown('left') then
        carSprite.rotation = carSprite.rotation - carSprite.rotationSpeed * dt
    end
    if love.keyboard.isDown('up') then -- Moving
        carSprite.speed = carSprite.speed + carSprite.accel * dt
        camerayShake = camerayShake - carSprite.accel / 5 * carSprite.speed / 1000
    elseif love.keyboard.isDown('down') then
        carSprite.speed = carSprite.speed - carSprite.accel * 1.5 * dt
        camerayShake = camerayShake + carSprite.accel / 5 * carSprite.speed / 1000
    end

    local dx = carSprite.speed * math.cos(carSprite.rotation)
    roadFrameMove = carSprite.speed * math.sin(carSprite.rotation)
    carSprite.x = carSprite.x + dx * dt

    -- Update collider position and rotation
    carCollider:moveTo(carSprite.x, carSprite.y)
    carCollider:rotate(carSprite.rotation - carCollider:rotation(), carCollider:center())
    table.insert(colliders, carCollider)

    -- Max Speed
    carSprite.speed = carSprite.speed * 0.999
    if carSprite.speed > 6500 then
        carSprite.speed = 6500
    end

    -- Update player camera
    cameraLERP(dt)
end

function cameraLERP(dt)
    if camerayShake > 100 then
        camerayShake = 100
    elseif camerayShake < -100 then
        camerayShake = -100
    end
    -- Calculate the distance to the player
    local dx = carSprite.x - camera.x
    local dy = carSprite.y - camera.y - camerayOffset - camerayShake
    camerayShake = camerayShake * 0.9

    local lerpFactor = 2 -- camera speed
    camera:move(dx * lerpFactor * dt, dy * lerpFactor * dt)
end

function loadTraffic()
    trafficImage = love.graphics.newImage("Sprites/yellowcar.png")
    trafficWarning = love.graphics.newImage("Sprites/trafficwarning.png")
    local scaleX = 0.5
    local scaleY = 0.5

    trafficRight = {
        x = 1750,
        y = -500,
        rotation = -math.pi/2,
        rotationX = trafficImage:getWidth() / 2,
        rotationY = trafficImage:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        speed = 750,
        width = trafficImage:getWidth() * scaleX,
        height = trafficImage:getHeight() * scaleY,
        image = trafficImage,
        timer = 1,
        flag = 0,
        crashed = 0,
        velocity = 0,
        nmtimer = 0
    }
    trafficLeft = {
        x = 0,
        y = -500,
        rotation = -math.pi/2,
        rotationX = trafficImage:getWidth() / 2,
        rotationY = trafficImage:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        speed = 750,
        width = trafficImage:getWidth() * scaleX,
        height = trafficImage:getHeight() * scaleY,
        image = trafficImage,
        timer = 1,
        flag = 0,
        crashed = 0,
        velocity = 0,
        nmtimer = 0
    }

    -- polygon colliders for the traffic
    trafficRightCollider = HC.polygon(
        trafficRight.x, trafficRight.y,
        trafficRight.x + trafficRight.width, trafficRight.y,
        trafficRight.x + trafficRight.width, trafficRight.y + trafficRight.height,
        trafficRight.x, trafficRight.y + trafficRight.height
    )
    trafficLeftCollider = HC.polygon(
        trafficLeft.x, trafficLeft.y,
        trafficLeft.x + trafficLeft.width, trafficLeft.y,
        trafficLeft.x + trafficLeft.width, trafficLeft.y + trafficLeft.height,
        trafficLeft.x, trafficLeft.y + trafficLeft.height
    )
    local nearMissColliderHeightOffset = 10
    local nearMissColliderWidthOffset = 75
    local awesomeMissColliderWidthOffset = 30

    -- polygon colliders for near miss
    trafficRightNearMissCollider = HC.polygon(
        trafficRight.x + nearMissColliderHeightOffset, trafficRight.y - nearMissColliderWidthOffset,
        trafficRight.x + trafficRight.width - nearMissColliderHeightOffset, trafficRight.y - nearMissColliderWidthOffset,
        trafficRight.x + trafficRight.width - nearMissColliderHeightOffset, trafficRight.y + trafficRight.height + nearMissColliderWidthOffset,
        trafficRight.x + nearMissColliderHeightOffset, trafficRight.y + trafficRight.height + nearMissColliderWidthOffset
    )
    trafficRightAwesomeMissCollider = HC.polygon(
        trafficRight.x + nearMissColliderHeightOffset, trafficRight.y - awesomeMissColliderWidthOffset,
        trafficRight.x + trafficRight.width - nearMissColliderHeightOffset, trafficRight.y - awesomeMissColliderWidthOffset,
        trafficRight.x + trafficRight.width - nearMissColliderHeightOffset, trafficRight.y + trafficRight.height + awesomeMissColliderWidthOffset,
        trafficRight.x + nearMissColliderHeightOffset, trafficRight.y + trafficRight.height + awesomeMissColliderWidthOffset
    )
    trafficLeftNearMissCollider = HC.polygon(
        trafficLeft.x + nearMissColliderHeightOffset, trafficLeft.y - nearMissColliderWidthOffset,
        trafficLeft.x + trafficLeft.width - nearMissColliderHeightOffset, trafficLeft.y - nearMissColliderWidthOffset,
        trafficLeft.x + trafficLeft.width - nearMissColliderHeightOffset, trafficLeft.y + trafficLeft.height + nearMissColliderWidthOffset,
        trafficLeft.x + nearMissColliderHeightOffset, trafficLeft.y + trafficLeft.height + nearMissColliderWidthOffset
    )
    trafficLeftAwesomeMissCollider = HC.polygon(
        trafficLeft.x + nearMissColliderHeightOffset, trafficLeft.y - awesomeMissColliderWidthOffset,
        trafficLeft.x + trafficLeft.width - nearMissColliderHeightOffset, trafficLeft.y - awesomeMissColliderWidthOffset,
        trafficLeft.x + trafficLeft.width - nearMissColliderHeightOffset, trafficLeft.y + trafficLeft.height + awesomeMissColliderWidthOffset,
        trafficLeft.x + nearMissColliderHeightOffset, trafficLeft.y + trafficLeft.height + awesomeMissColliderWidthOffset
    )
    
end

function updateTraffic(dt)
    trafficRight.timer = trafficRight.timer - dt
    trafficLeft.timer = trafficLeft.timer - dt
    trafficRight.nmtimer = trafficRight.nmtimer - dt
    trafficLeft.nmtimer = trafficLeft.nmtimer - dt

    if trafficRight.nmtimer < 0 then
        trafficRight.nmtimer = 0
    end
    if trafficLeft.nmtimer < 0 then
        trafficLeft.nmtimer = 0
    end

    if trafficRight.timer < 0 then
        trafficRight.timer = 0
    end
    if trafficLeft.timer < 0 then
        trafficLeft.timer = 0
    end

    if trafficRight.timer < 1 and trafficRight.timer > 0 then
        trafficRight.image = trafficWarning
        trafficRight.y = 150
    end
    if trafficLeft.timer < 1 and trafficLeft.timer > 0 then
        trafficLeft.image = trafficWarning
        trafficLeft.y = 150
    end

    if trafficRight.timer == 0 and trafficRight.crashed == 0 then
        trafficRight.image = trafficImage
        trafficRight.y = trafficRight.y + (-roadFrameMove - trafficRight.speed) * dt
    elseif trafficRight.crashed == 1 then
        trafficRight.y = trafficRight.y + -roadFrameMove * dt
    end
    if trafficLeft.timer == 0 and trafficLeft.crashed == 0 then
        trafficLeft.image = trafficImage
        trafficLeft.y = trafficLeft.y + (-roadFrameMove - trafficLeft.speed) * dt
    elseif trafficLeft.crashed == 1 then
        trafficLeft.y = trafficLeft.y + -roadFrameMove * dt
    end

    if trafficRight.y > screenHeight + 500 then
        trafficRight.timer = math.random(1.5, 4)
        trafficRight.y = -500
        trafficRight.x = math.random(1500, 2000)
        trafficRight.crashed = 0
        trafficRight.rotation = -math.rad(90)
    end

    if trafficLeft.y > screenHeight + 500 then
        trafficLeft.timer = math.random(1.5, 4)
        trafficLeft.y = -500
        trafficLeft.x = math.random(-100, 500)
        trafficLeft.crashed = 0
        trafficLeft.rotation = -math.rad(90)
    end

    if trafficRight.crashed == 1 then
        trafficRight.x = trafficRight.x + 100 * dt
        trafficRight.rotation = trafficRight.rotation + math.rad(45) * dt
        trafficRight.y = trafficRight.y - trafficRight.velocity * dt
    end
    if trafficLeft.crashed == 1 then
        trafficLeft.x = trafficLeft.x - 100 * dt
        trafficLeft.rotation = trafficLeft.rotation + math.rad(45) * dt
        trafficLeft.y = trafficLeft.y - trafficLeft.velocity * dt
    end

    if trafficRight.nmtimer == 0 then
        if trafficRight.flag == 2 then
            print("Awesome near miss")
            trafficRight.flag = 0
        elseif trafficRight.flag == 1 then
            print("Near miss")
            trafficRight.flag = 0
        end
    end
    if trafficLeft.nmtimer == 0 then
        if trafficLeft.flag == 2 then
            print("Awesome near miss")
            trafficLeft.flag = 0
        elseif trafficLeft.flag == 1 then
            print("Near miss")
            trafficLeft.flag = 0
        end
    end

    -- Update colliders
    trafficRightCollider:moveTo(trafficRight.x, trafficRight.y)
    trafficRightCollider:rotate(trafficRight.rotation - trafficRightCollider:rotation(), trafficRightCollider:center())
    trafficLeftCollider:moveTo(trafficLeft.x, trafficLeft.y)
    trafficLeftCollider:rotate(trafficLeft.rotation - trafficLeftCollider:rotation(), trafficLeftCollider:center())
    table.insert(colliders, trafficRightCollider)
    table.insert(colliders, trafficLeftCollider)

    -- Update near miss colliders
    trafficRightNearMissCollider:moveTo(trafficRight.x, trafficRight.y)
    trafficRightNearMissCollider:rotate(trafficRight.rotation - trafficRightNearMissCollider:rotation(), trafficRightNearMissCollider:center())
    trafficRightAwesomeMissCollider:moveTo(trafficRight.x, trafficRight.y)
    trafficRightAwesomeMissCollider:rotate(trafficRight.rotation - trafficRightAwesomeMissCollider:rotation(), trafficRightAwesomeMissCollider:center())
    trafficLeftNearMissCollider:moveTo(trafficLeft.x, trafficLeft.y)
    trafficLeftNearMissCollider:rotate(trafficLeft.rotation - trafficLeftNearMissCollider:rotation(), trafficLeftNearMissCollider:center())
    trafficLeftAwesomeMissCollider:moveTo(trafficLeft.x, trafficLeft.y)
    trafficLeftAwesomeMissCollider:rotate(trafficLeft.rotation - trafficLeftAwesomeMissCollider:rotation(), trafficLeftAwesomeMissCollider:center())
    table.insert(colliders, trafficRightNearMissCollider)
    table.insert(colliders, trafficRightAwesomeMissCollider)
    table.insert(colliders, trafficLeftNearMissCollider)
    table.insert(colliders, trafficLeftAwesomeMissCollider)

    -- Deal with near misses
    if carCollider:collidesWith(trafficRightAwesomeMissCollider) and trafficRight.crashed == 0 then
        trafficRight.flag = 2
        trafficRight.nmtimer = 0.05
    elseif carCollider:collidesWith(trafficRightNearMissCollider) and trafficRight.crashed == 0 and trafficRight.flag ~= 2 then
        trafficRight.flag = 1
        trafficRight.nmtimer = 0.05
    end
    if carCollider:collidesWith(trafficLeftAwesomeMissCollider) and trafficLeft.crashed == 0 then
        trafficLeft.flag = 2
        trafficLeft.nmtimer = 0.05
    elseif carCollider:collidesWith(trafficLeftNearMissCollider) and trafficLeft.crashed == 0 and trafficLeft.flag ~= 2  then
        trafficLeft.flag = 1
        trafficLeft.nmtimer = 0.05
    end

    -- Deal with collisions
    if carCollider:collidesWith(trafficRightCollider) then --and trafficRight.crashed == 0 then
        carSprite.speed = carSprite.speed * 0.75
        camerayShake = camerayShake + 1000
        trafficRight.crashed = 1
        trafficRight.y = carSprite.y - 275
        trafficRight.velocity = carSprite.speed * 1.5
        trafficRight.flag = 0
    elseif carCollider:collidesWith(trafficLeftCollider) then --and trafficLeft.crashed == 0 then
        carSprite.speed = carSprite.speed * 0.75
        camerayShake = camerayShake + 1000
        trafficLeft.crashed = 1
        trafficLeft.y = carSprite.y - 275
        trafficLeft.velocity = carSprite.speed * 1.5
        trafficLeft.flag = 0
    end


    trafficRight.velocity = trafficRight.velocity * 0.98
    trafficLeft.velocity = trafficLeft.velocity * 0.98
end

function loadPolice()
    local policeImage = love.graphics.newImage("Sprites/yellowcar.png")
    scaleX = 0.5
    scaleY = 0.5
    policeHeat = 0
    policeSprite = {
        x = 1000,
        y = 500,
        rotation = -math.pi/2,
        rotationX = trafficImage:getWidth() / 2,
        rotationY = trafficImage:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        speed = 2200,
        acc = 200,
        width = trafficImage:getWidth() * scaleX,
        height = trafficImage:getHeight() * scaleY,
        image = policeImage,
        timer = 1,
        flag = 0,
        crashed = 0,
        velocity = 0,
        prevX = 1000,
        prevY = 2200,
    }

    -- polygon colliders for the police
    policeCollider = HC.polygon(
        policeSprite.x, policeSprite.y,
        policeSprite.x + policeSprite.width, policeSprite.y,
        policeSprite.x + policeSprite.width, policeSprite.y + policeSprite.height,
        policeSprite.x, policeSprite.y + policeSprite.height
    )
end

function updatePolice(dt)
    policeSprite.timer = policeSprite.timer - dt

    if policeSprite.timer < 0 then
        policeSprite.timer = 0
    end

    local playerDifferencex = policeSprite.x - carSprite.x
    local prevplayerDifferencex = policeSprite.prevX - carSprite.prevX
    local rateOfChangex = playerDifferencex - prevplayerDifferencex
    local px = 0.003
    local dx = 0.001
    local playerDifferencey = policeSprite.y - carSprite.y + 500
    local prevplayerDifferencey = policeSprite.prevY - carSprite.prevY + 500
    local rateOfChangey = playerDifferencey - prevplayerDifferencey
    local py = 0.05
    local dy = 0.01

    if policeSprite.crashed == 0 then
        if playerDifferencex < 0 then
            -- Right
            policeSprite.rotation = policeSprite.rotation + dt * (px * math.abs(playerDifferencex) + dx * rateOfChangex)
        elseif playerDifferencex > 0 then
            -- Left
            policeSprite.rotation = policeSprite.rotation - dt * (px * math.abs(playerDifferencex) + dx * rateOfChangex)
        end

        if playerDifferencey < 0 then
            -- Slow
            policeSprite.speed = policeSprite.speed - dt * (py * math.abs(playerDifferencey) + dx * rateOfChangey)
        elseif playerDifferencey > 0 then
            -- Faster
            policeSprite.speed = policeSprite.speed + dt * (py * math.abs(playerDifferencey) + dx * rateOfChangey)
        end

        if policeSprite.speed < 800 then
            policeSprite.speed = 800
        elseif policeSprite.speed > 8000 then
            policeSprite.speed = 8000
        end

        policeSprite.rotation = math.max(math.min(policeSprite.rotation, -math.pi/3), -2*math.pi/3)

        local dx = policeSprite.speed * math.cos(policeSprite.rotation)
        local dy = policeSprite.speed * math.sin(policeSprite.rotation)
        policeSprite.x = policeSprite.x + dx * dt
        policeSprite.y = policeSprite.y + (-roadFrameMove + dy) * dt
    elseif policeSprite.crashed == 1 then
        policeSprite.y = policeSprite.y + -roadFrameMove * dt
    end
    print(policeSprite.speed)
    
    if policeSprite.y > screenHeight + 500 then
        policeSprite.timer = math.random(1, 3)
        policeSprite.y = -500
        policeSprite.x = math.random(750, 1500)
        policeSprite.crashed = 0
        policeSprite.rotation = -math.rad(90)
        policeSprite.speed = carSprite.speed
    elseif policeSprite.y < -screenHeight then
        policeSprite.y = -500
        policeSprite.x = math.random(750, 1500)
        policeSprite.rotation = -math.rad(90)
        policeSprite.speed = carSprite.speed
    end

    
    policeSprite.speed = policeSprite.speed

    -- Update PD control
    policeSprite.prevX = policeSprite.x
    carSprite.prevX = carSprite.x

    -- Update colliders
    policeCollider:moveTo(policeSprite.x, policeSprite.y)
    policeCollider:rotate(policeSprite.rotation - policeCollider:rotation(), policeCollider:center())
    table.insert(colliders, policeCollider)
end

function loadRoad()
    image = love.graphics.newImage("Sprites/road1.png")
    roadScale = 4
    
    road = {
        image = image, -- Art pass comes later ..
        x = ((screenWidth / 2) - (roadScale * image:getWidth() / 2)),
        v1y = 0,
        v2y = image:getHeight() * roadScale,
        scaleX = roadScale,
        scaleY = roadScale,
    }

    rightRoadColliderOffset = 1570
    leftRoadColliderOffset = 1570

    rightRoadCollider = HC.polygon(
        ((road.x + road.image:getWidth() / 2) + rightRoadColliderOffset), 0,
        ((road.x + road.image:getWidth() / 2) + rightRoadColliderOffset) + 50, 0,
        ((road.x + road.image:getWidth() / 2) + rightRoadColliderOffset) + 50, 2000,
        ((road.x + road.image:getWidth() / 2) + rightRoadColliderOffset), 2000
    )
    leftRoadCollider = HC.polygon(
        ((road.x + road.image:getWidth() / 2) - leftRoadColliderOffset), 0,
        ((road.x + road.image:getWidth() / 2) - leftRoadColliderOffset) - 50, 0,
        ((road.x + road.image:getWidth() / 2) - leftRoadColliderOffset) - 50, 2000,
        ((road.x + road.image:getWidth() / 2) - leftRoadColliderOffset), 2000
    )
    table.insert(colliders, rightRoadCollider)
    table.insert(colliders, leftRoadCollider)
end

function roadUpdate(dt)
    road.v1y = road.v1y - roadFrameMove * dt
    road.v2y = road.v2y - roadFrameMove * dt

    if roadFrameMove > 0 then
        if road.v1y < -road.image:getHeight() * road.scaleY then
            road.v1y = road.v2y + road.image:getHeight() * road.scaleY
        end

        if road.v2y < -road.image:getHeight() * road.scaleY then
            road.v2y = road.v1y + road.image:getHeight() * road.scaleY
        end

    elseif roadFrameMove < 0 then
        if road.v1y > road.image:getHeight() * road.scaleY then
            road.v1y = road.v2y - road.image:getHeight() * road.scaleY
        end

        if road.v2y > road.image:getHeight() * road.scaleY then
            road.v2y = road.v1y - road.image:getHeight() * road.scaleY
        end
    end
    -- Update colliders
    rightRoadCollider:moveTo(((road.x + road.image:getWidth() * road.scaleX / 2) + rightRoadColliderOffset), 1000)
    leftRoadCollider:moveTo(((road.x + road.image:getWidth() * road.scaleX / 2) - leftRoadColliderOffset), 1000)
    table.insert(colliders, rightRoadCollider)
    table.insert(colliders, leftRoadCollider)

    -- Check collider collisions
    if carCollider:collidesWith(rightRoadCollider) then
        carSprite.x = (road.x + road.image:getWidth() * road.scaleX / 2) + rightRoadColliderOffset - (carSprite.image:getWidth() / 3)
        carSprite.rotation = -math.rad(90 + 15)
        carSprite.speed = carSprite.speed - 250
        camerayShake = camerayShake + 200
        print(carSprite.speed)
    elseif carCollider:collidesWith(leftRoadCollider) then
        carSprite.x = (road.x + road.image:getWidth() * road.scaleX / 2) - leftRoadColliderOffset + (carSprite.image:getWidth() / 3)
        carSprite.rotation = -math.rad(90 - 15)
        carSprite.speed = carSprite.speed - 250
        camerayShake = camerayShake + 200
        print(carSprite.speed)
    end
    if carSprite.speed < 800 then
        carSprite.speed = 800
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