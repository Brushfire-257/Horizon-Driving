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
local endAnimation = 0

function deathAnim.load()
    -- Scaling init
    CScreen.init(math.max(love.graphics.getWidth(), 1920), 1080, debugMode)

    love.window.setTitle("Horizon Driving - Game Endscreen")
    screenWidthA = love.graphics.getWidth()
    screenHeightA = love.graphics.getHeight()

    loadAnimations()
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
    
    CScreen.cease()
end

function loadAnimations()
    animScale = 1

    menuAnimationImages = {
        playerCar = love.graphics.newImage("Sprites/yellowcar.png"),
        trafficCar = love.graphics.newImage("Sprites/yellowcar.png"),
        road = love.graphics.newImage("Sprites/road1.png"),
    }

    mac = { -- Menu animation container
        playerx = 400, -- Player Car
        playery = 200,
        playerRotation = 0,
        playerRotationX = menuAnimationImages.playerCar:getWidth() / 2,
        playerRotationY = menuAnimationImages.playerCar:getHeight() / 2,
        playerScaleX = animScale,
        playerScaleY = animScale,
        playerAppear = 1,
        playerImage = menuAnimationImages.playerCar,

        trafficx = 500, -- Traffic Car
        trafficy = 500,
        trafficRotation = 0,
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

        timer = 4,
        counter = 0
    }
end

function updateAnimations(dt)
    darkOffset = 0
    local darkDifference = darkOffset - darkCurrent
    darkCurrent = darkCurrent + darkDifference * 0.2

    mac.timer = mac.timer - dt

    if mac.timer <= 0 then endAnimation = 1 end

    mac.road1x = mac.road1x - 1

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