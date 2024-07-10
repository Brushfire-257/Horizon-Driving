-- The player death animation before the game end screen
deathAnim = {}

-- library setup
local CScreen = require "cscreen"

-- misc. setup
local screenWidthA = love.graphics.getWidth()
local screenHeightA = love.graphics.getHeight()
local screenWidth = 1920
local screenHeight = 1080

local darkOffset = 0
local darkCurrent = 0

-- anim setup
local animatedDebris = {}
local mac = {}
local endAnimation = 0

function deathAnim.load()
    -- Scaling init
    CScreen.init(math.max(love.graphics.getWidth(), 1920), 1080, debugMode)

    love.window.setTitle("Horizon Driving - Game Endscreen")
    screenWidthA = love.graphics.getWidth()
    screenHeightA = love.graphics.getHeight()

    endAnimation = 0

    loadAnimations()
    -- print("Animations loaded")
end

function deathAnim.update(dt)

    updateAnimations(dt)

    if love.keyboard.isDown('p') then -- DEBUG
        return "playerDeath"
    end

    if endAnimation == 1 then
        return "gameEndscreen"
    end

    return nil
end

function deathAnim.draw()
    CScreen.apply()
    love.graphics.setColor(1 - darkCurrent, 1 - darkCurrent, 1 - darkCurrent, 1)
    -- Draw Background
    love.graphics.draw(mac.roadImage, math.floor(mac.road1x),
    math.floor(mac.road1y), mac.roadRotation,
    mac.roadScaleX, mac.roadScaleY,
    mac.roadRotationX, mac.roadRotationY)
    love.graphics.draw(mac.roadImage, math.floor(mac.road2x),
    math.floor(mac.road2y), mac.roadRotation,
    mac.roadScaleX, mac.roadScaleY,
    mac.roadRotationX, mac.roadRotationY)

    if mac.trafficAppear == 1 then
        love.graphics.draw(mac.trafficImage, math.floor(mac.trafficx),
        math.floor(mac.trafficy), mac.trafficRotation,
        mac.trafficScaleX, mac.trafficScaleY,
        mac.trafficRotationX, mac.trafficRotationY)
    end
    if mac.playerAppear == 1 then
        love.graphics.draw(mac.playerImage, math.floor(mac.playerx),
        math.floor(mac.playery), mac.playerRotation,
        mac.playerScaleX, mac.playerScaleY,
        mac.playerRotationX, mac.playerRotationY)
    end
    local debrisImage = love.graphics.newImage("Sprites/debris.png")
    local debrisRX = debrisImage:getWidth() / 2
    local debrisRY = debrisImage:getHeight() / 2
    for i, debris in ipairs(animatedDebris) do
        love.graphics.setColor(1 - darkCurrent, 1 - darkCurrent, 1 - darkCurrent, debris.alpha)
            love.graphics.draw(debrisImage, debris.x, debris.y, debris.rotation, debris.scaleX, debris.scaleY,
            debrisRX, debrisRY)
            love.graphics.setColor(1 - darkCurrent, 1 - darkCurrent, 1 - darkCurrent, 1)
    end

    drawRectangle(mac.box1x, mac.box1y, mac.box1Width, mac.box1Height, mac.box1Rotation, mac.box1Color)
    drawRectangle(mac.box2x, mac.box2y, mac.box2Width, mac.box2Height, mac.box2Rotation, mac.box2Color)
    
    CScreen.cease()
end

function drawRectangle(x, y, width, height, rotation, color)
    -- Save the current transformation
    love.graphics.push()

    -- Set the color
    if color then
        love.graphics.setColor(color)
    end

    -- Translate to the rectangle's location
    if x and y then
        love.graphics.translate(x, y)
    end

    -- Rotate by the rectangle's rotation
    if rotation then
        love.graphics.rotate(rotation)
    end

    -- Draw the rectangle
    if width and height then
        love.graphics.rectangle('fill', -width / 2, -height / 2, width, height)
    end

    -- Restore the transformation
    love.graphics.pop()
end

function loadAnimations()
    animScale = 1

    menuAnimationImages = {
        playerCar = love.graphics.newImage("Sprites/yellowcar.png"),
        trafficCar = love.graphics.newImage("Sprites/yellowcar.png"),
        road = love.graphics.newImage("Sprites/road1.png"),
    }

    mac = { -- Menu animation container
        playerx = 600, -- Player Car
        playery = 500,
        playerRotation = 0,
        playerRotationX = menuAnimationImages.playerCar:getWidth() / 2,
        playerRotationY = menuAnimationImages.playerCar:getHeight() / 2,
        playerScaleX = animScale,
        playerScaleY = animScale,
        playerAppear = 1,
        playerImage = menuAnimationImages.playerCar,

        trafficx = 1050, -- Traffic Car
        trafficy = 500,
        trafficRotation = math.rad(-25),
        trafficRotationX = menuAnimationImages.trafficCar:getWidth() / 2,
        trafficRotationY = menuAnimationImages.trafficCar:getHeight() / 2,
        trafficScaleX = animScale,
        trafficScaleY = animScale,
        trafficAppear = 1,
        trafficImage = menuAnimationImages.trafficCar,

        road1x = 0,
        road2x = 0,
        road1y = 2600,
        road2y = 0,
        roadRotation = math.rad(90),
        roadRotationX = menuAnimationImages.road:getWidth() / 2,
        roadRotationY = menuAnimationImages.road:getHeight() / 2,
        roadScaleX = animScale * 8,
        roadScaleY = animScale * 8,
        roadAppear = 0,
        roadImage = menuAnimationImages.road,

        box1x = screenWidth/3,
        box1y = 0,
        box1Rotation = math.rad(45),
        box1Width = screenHeight+100,
        box1Height = 50,
        box1Color = {1, 0, 0},
        box2x = 2*screenWidth/3,
        box2y = screenHeight,
        box2Rotation = math.rad(45),
        box2Width = screenHeight+100,
        box2Height = 50,
        box2Color = {1, 0, 0},
        boxAlpha = 1,

        timer = 4,
        counter = 0
    }

    addDebris(950, 550, 0, 3.6, -.1, -.005)
    addDebris(850, 450, 1, 3.5, -.1, .004)
    addDebris(850, 400, 2, 3.4, -.1, -.003)
    addDebris(900, 350, 2, 3.5, -.1, .003)
    addDebris(750, 400, 2, 3.7, -.1, -.004)
end

function updateAnimations(dt)
    local darkDifference = darkOffset - darkCurrent
    darkCurrent = darkCurrent + darkDifference * 0.2

    print(mac.timer)

    mac.timer = mac.timer - dt

    if mac.timer <= 0 then endAnimation = 1 end

    if mac.timer <= 0.3 then darkOffset = 1 end

    mac.road1x = mac.road1x - 1

    mac.playerx = mac.playerx + 4
    mac.trafficx = mac.trafficx + 4.2

    -- mac.playery = mac.playery + 0.1
    mac.trafficy = mac.trafficy - 0.15

    mac.playerRotation = mac.playerRotation + math.rad(0.2)
    mac.trafficRotation = mac.trafficRotation + math.rad(-0.16)

    updateRoad()
    updateDebris2()
end

function updateRoad()
    -- mac.road1x = math.floor(mac.road1x)
    -- mac.road1y = math.floor(mac.road1y)
    local roadEndX = mac.road1x - (mac.roadImage:getHeight() * (animScale * 8)) * math.cos(mac.roadRotation + math.rad(90))
    local roadEndY = mac.road1y - (mac.roadImage:getHeight() * (animScale * 8)) * math.sin(mac.roadRotation + math.rad(90))

    mac.road2x = roadEndX
    mac.road2y = roadEndY
end

function addDebris(x, y, rotation, speedX, speedY, rotationSpeed)
    local debris = {
        x = x,
        y = y,
        rotation = rotation,
        speedx = speedX,
        speedy = speedY,
        rotationSpeed = rotationSpeed,
        scaleX = animScale,
        scaleY = animScale,
        alpha = 1,
    }
    table.insert(animatedDebris, debris)
end

function clearDebris()
    animatedDebris = {}
end

function updateDebris2()
    for i, debris in ipairs(animatedDebris) do
        debris.x = debris.x + debris.speedx
        debris.y = debris.y + debris.speedy
        debris.rotation = debris.rotation + debris.rotationSpeed
    end
end

function love.keypressed(key)
    if key == "1" then -- Exit the game (Debug)
      love.event.quit()
    end
end

function scaleStuff(widthorheight)
    local scale = 1
    if widthorheight == "w" then -- width calc
        scale = screenWidthA / screenWidth
    elseif widthorheight == "h" then -- height calc
        scale = screenHeightA / screenHeight
    else
        print("Function usage error: scaleStuff() w/h not specified.")
    end

    return scale
end

return deathAnim