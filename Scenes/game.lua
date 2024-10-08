-- The arcade loop for the game.

-- Scene container
arcadeGame = {}

-- misc. setup
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local timer = 0
local colliders = {}

local backgroundSpeed = 0

local gameSpeed = 1
local actualGameSpeed = gameSpeed

local exitGame = 0

-- Player Stats
policeTakedowns = 0
distanceTraveled = 0
EMPDodges = 0
nearMisses = 0
awesomeNearMisses = 0
timeSurvived = 0

-- Police anim
local policeAnimTimer = 0
local currentFrame = 1
local timePerFrame = 0.07

policeAnimationSequence = {
    love.graphics.newImage("Sprites/Cars/PoliceAnim/police c7 red.png"), love.graphics.newImage("Sprites/Cars/PoliceAnim/police c7.png"),
    love.graphics.newImage("Sprites/Cars/PoliceAnim/police c7 red.png"), love.graphics.newImage("Sprites/Cars/PoliceAnim/police c7.png"),
    love.graphics.newImage("Sprites/Cars/PoliceAnim/police c7 blue.png"), love.graphics.newImage("Sprites/Cars/PoliceAnim/police c7.png"),
    love.graphics.newImage("Sprites/Cars/PoliceAnim/police c7 blue.png"), love.graphics.newImage("Sprites/Cars/PoliceAnim/police c7.png")
}

font1 = love.graphics.newFont("fonts/VCR_OSD_MONO.ttf", 75 * math.min(scaleStuff("w"), scaleStuff("h")))

-- Libraries
HC = require 'libraries/HardonCollider'
local Camera = require 'libraries/hump.camera'
local CScreen = require 'libraries/cscreen'

function arcadeGame.load() -- Runs once at the start of the game.
    love.graphics.setFont(font1)

    gameSpeed = 1

    tutorialStage = 1
    pressedMovementkeys = 0
    tutorialTimer = 1
    pressedNitroKey = 0

    -- Load window values
    -- love.window.setMode(1280, 720) -- Set to 1920 x 1080 on launch
    love.window.setTitle("Horizon Driving - Arcade Mode")
    
    -- Load Game settings (currently just debug mode)
    local settingsStr = love.filesystem.read("settings.txt")
    loadSettings(settingsStr)

    -- Reseed RNG
    love.math.setRandomSeed(os.time())

    -- Scaling init
    CScreen.init(math.max(love.graphics.getWidth(), 1920), 1080, 1)
    
    -- Create the sound manager
    soundManager = SoundManager:new()

    -- misc. setup
    -- screenWidth = math.min(love.graphics.getWidth(), 1920)
    -- screenHeight = math.min(love.graphics.getHeight(), 1080)
    screenWidth = math.max(love.graphics.getWidth(), 1920)
    screenHeight = 1080
    timer = 0
    colliders = {}
    backgroundSpeed = 0
    gameSpeed = 1
    actualGameSpeed = gameSpeed
    exitGame = 0

    -- Player Stats
    policeTakedowns = 0
    distanceTraveled = 0
    EMPDodges = 0
    nearMisses = 0
    awesomeNearMisses = 0
    timeSurvived = 0

    -- Load stuff
    loadSongs()
    loadCar()
    loadRoad()
    loadTraffic()
    loadPolice()
    loadGUI()
    loadDebris()
    loadSpikestrip()
    loadEMP()

    -- Create camera
    camerayOffset = (1080 / 2) - (love.graphics.getHeight() / 2) + 360
    cameraxScaleOffset = (1920 / 2) - (love.graphics.getWidth() / 2)
    GUIyOffset = 0
    GUIxOffset = 0
    camerayShake = 0
    cameraxOffset = 0
    camerayOffset1 = 0
    takedownCamera = 0
    takedownCameraTimer = 0
    camera = Camera(carSprite.x - cameraxScaleOffset, carSprite.y - camerayOffset)
end

function arcadeGame.update(dt) -- Runs every frame.
    colliders = {} -- clear the table for new values
    
    if takedownCameraTimer > 0 and exitGame == 0 then
        gameSpeed = 0.15
    elseif exitGame == 0 then
        gameSpeed = 1
    end

    if (actualGameSpeed - gameSpeed) < 0 then
        actualGameSpeed = actualGameSpeed - (actualGameSpeed - gameSpeed) * dt * 5
    else
        actualGameSpeed = actualGameSpeed - (actualGameSpeed - gameSpeed) * dt * 3
    end
    dt = dt * actualGameSpeed

    playerUpdate(dt)
    roadUpdate(dt)
    updateTraffic(dt)
    updatePolice(dt)
    updateGUI(dt)
    updateDebris(dt)
    updateSpikestrip(dt)
    updateEMP(dt)
    tutorialUpdate(dt)

    timeSurvived = timeSurvived + dt
    
    -- Exit game?
    if exitGame == 1 and actualGameSpeed <= 0.1 then
        gamespeed = 1
        actualGameSpeed = gamespeed
        love.audio.stop()
        return "playerDeath"
    end

    -- Moved down here so it only updates if the game is actually running
    soundManager:update(dt)
end

function arcadeGame.draw() -- Draws every frame / Runs directly after love.update()
    if exitGame == 1 then
        love.graphics.setColor(1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end

    CScreen.apply()

    camera:attach()
    love.graphics.draw(road.image, math.floor(road.x), math.floor(road.v1y), 0, road.scaleX, road.scaleY) -- Draws the road sprites
    love.graphics.draw(road.image, math.floor(road.x), math.floor(road.v2y), 0, road.scaleX, road.scaleY)

    shadowAngle = math.rad(0)
    shadowDistance = 15

    -- Shadows
    drawShadow(carSprite.image, carSprite.x, carSprite.y, carSprite.rotation,
    shadowAngle, shadowDistance, carSprite.scaleX, carSprite.scaleY, carSprite.rotationX, carSprite.rotationY)

    drawShadow(policeSprite.image, policeSprite.x, policeSprite.y, policeSprite.rotation,
    shadowAngle, shadowDistance, policeSprite.scaleX, policeSprite.scaleY, policeSprite.rotationX, policeSprite.rotationY)

    drawShadow(trafficLeft.image, trafficLeft.x, trafficLeft.y, trafficLeft.rotation,
    shadowAngle, shadowDistance, trafficLeft.scaleX, trafficLeft.scaleY, trafficLeft.rotationX, trafficLeft.rotationY)
    drawShadow(trafficRight.image, trafficRight.x, trafficRight.y, trafficRight.rotation,
    shadowAngle, shadowDistance, trafficRight.scaleX, trafficRight.scaleY, trafficRight.rotationX, trafficRight.rotationY)

    drawSkidMarks()

    if exitGame == 1 then
        love.graphics.setColor(1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end


    if trafficRight.timer < 1 and trafficRight.timer > 0 then
        love.graphics.draw(trafficRight.image, trafficRight.x, trafficRight.y + trafficRight.warningOffset, trafficRight.rotation, trafficRight.scaleX, trafficRight.scaleY,
        trafficRight.rotationX, trafficRight.rotationY)
    else
        love.graphics.draw(trafficRight.image, trafficRight.x, trafficRight.y, trafficRight.rotation, trafficRight.scaleX, trafficRight.scaleY,
        trafficRight.rotationX, trafficRight.rotationY)
    end
    if trafficLeft.timer < 1 and trafficLeft.timer > 0 then
        love.graphics.draw(trafficLeft.image, trafficLeft.x, trafficLeft.y + trafficLeft.warningOffset, trafficLeft.rotation, trafficLeft.scaleX, trafficLeft.scaleY,
        trafficLeft.rotationX, trafficLeft.rotationY)
    else
        love.graphics.draw(trafficLeft.image, trafficLeft.x, trafficLeft.y, trafficLeft.rotation, trafficLeft.scaleX, trafficLeft.scaleY,
        trafficLeft.rotationX, trafficLeft.rotationY)
    end

    love.graphics.draw(policeSprite.image, policeSprite.x, policeSprite.y, policeSprite.rotation, policeSprite.scaleX, policeSprite.scaleY,
    policeSprite.rotationX, policeSprite.rotationY)
    
    if spikestripSprite.visible == 1 then
        love.graphics.draw(spikestripSprite.image, math.floor(spikestripSprite.x), math.floor(spikestripSprite.y), spikestripSprite.rotation, spikestripSprite.scaleX, spikestripSprite.scaleY,
        spikestripSprite.rotationX, spikestripSprite.rotationY)
    end
    
    
    if nitroSprite.appear == 1 then
        love.graphics.draw(nitroSprite.image, nitroSprite.x, nitroSprite.y, nitroSprite.rotation, nitroSprite.scaleX, nitroSprite.scaleY,
        nitroSprite.rotationX, nitroSprite.rotationY) -- Nitro
    end
    love.graphics.draw(carSprite.image, carSprite.x, carSprite.y, carSprite.rotation, carSprite.scaleX, carSprite.scaleY,
    carSprite.rotationX, carSprite.rotationY) -- Draws the car sprite
    
    for i, debris in ipairs(debrisTable) do
        if debris.image then
            if exitGame == 1 then
                love.graphics.setColor(1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), debris.alpha)
            else
                love.graphics.setColor(1, 1, 1, debris.alpha)
            end
            love.graphics.draw(debris.image, debris.x, debris.y, debris.rotation, debris.scaleX, debris.scaleY,
            debris.rotationX, debris.rotationY)
            if exitGame == 1 then
                love.graphics.setColor(1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1)
            else
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end

    if EMPSprite.visible == 1 and takedownCameraTimer == 0 then
        love.graphics.draw(EMPSprite.image, EMPSprite.x, EMPSprite.y, EMPSprite.rotation, EMPSprite.scaleX, EMPSprite.scaleY,
        EMPSprite.rotationX, EMPSprite.rotationY)

    end
    if takedownCameraTimer == 0 then
        for i, EMPSprite in ipairs(EMPCopies) do
            if EMPSprite.image then
                if exitGame == 1 then
                    love.graphics.setColor(1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), EMPSprite.alpha)
                else
                    love.graphics.setColor(1, 1, 1, EMPSprite.alpha)
                end
                love.graphics.draw(EMPSprite.image, EMPSprite.x, EMPSprite.y, EMPSprite.rotation, EMPSprite.scaleX, EMPSprite.scaleY,
                EMPSprite.rotationX, EMPSprite.rotationY)
                if exitGame == 1 then
                    love.graphics.setColor(1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1)
                else
                    love.graphics.setColor(1, 1, 1, 1)
                end
            end
        end
    end

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
        if exitGame == 1 then
            love.graphics.setColor(1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
    camera:detach()
    love.graphics.translate(0, GUIyOffset)

    -- Draw the GUI
    if displayGUI == 1 then
        local GUIShakex = math.random(-2, 2) * (carSprite.speed/2000)
        local GUIShakey = math.random(-2, 2) * (carSprite.speed/2000)

        love.graphics.draw(speedNumber1.image, math.floor(speedNumber1.x + GUIShakex + GUIxOffset), math.floor(speedNumber1.y + GUIShakey), speedNumber1.rotation, speedNumber1.scaleX, speedNumber1.scaleY,
        speedNumber1.rotationX, speedNumber1.rotationY)
        love.graphics.draw(speedNumber2.image, math.floor(speedNumber2.x + GUIShakex + GUIxOffset), math.floor(speedNumber2.y + GUIShakey), speedNumber2.rotation, speedNumber2.scaleX, speedNumber2.scaleY,
        speedNumber2.rotationX, speedNumber2.rotationY)
        love.graphics.draw(speedNumber3.image, math.floor(speedNumber3.x + GUIShakex + GUIxOffset), math.floor(speedNumber3.y + GUIShakey), speedNumber3.rotation, speedNumber3.scaleX, speedNumber3.scaleY,
        speedNumber3.rotationX, speedNumber3.rotationY)

        love.graphics.draw(nitroBar.image, math.floor(nitroBar.x + GUIShakex + GUIxOffset), math.floor(nitroBar.y + GUIShakey), nitroBar.rotation, nitroBar.scaleX, nitroBar.scaleY,
        nitroBar.rotationX, nitroBar.rotationY)

        love.graphics.draw(healthBar.image, math.floor(healthBar.x + GUIShakex - GUIxOffset), math.floor(healthBar.y + GUIShakey), healthBar.rotation, healthBar.scaleX, healthBar.scaleY,
        healthBar.rotationX, healthBar.rotationY)

        love.graphics.draw(heatIndicator.image, math.floor(heatIndicator.x + GUIShakex - GUIxOffset), math.floor(heatIndicator.y + GUIShakey), heatIndicator.rotation, heatIndicator.scaleX, heatIndicator.scaleY,
        heatIndicator.rotationX, heatIndicator.rotationY)
        love.graphics.draw(heatIndicatorNumber.image, math.floor(heatIndicatorNumber.x + GUIShakex - GUIxOffset), math.floor(heatIndicatorNumber.y + GUIShakey), heatIndicatorNumber.rotation, heatIndicatorNumber.scaleX, heatIndicatorNumber.scaleY,
        heatIndicatorNumber.rotationX, heatIndicatorNumber.rotationY)
    end

    -- if takedownCameraTimer > 0 then
    love.graphics.draw(takedownOverlayTop.image, math.floor(takedownOverlayTop.x), math.floor(takedownOverlayTop.y), takedownOverlayTop.rotation, takedownOverlayTop.scaleX, takedownOverlayTop.scaleY,
    takedownOverlayTop.rotationX, takedownOverlayTop.rotationY)
    love.graphics.draw(takedownOverlayBottom.image, math.floor(takedownOverlayBottom.x), math.floor(takedownOverlayBottom.y), takedownOverlayBottom.rotation, takedownOverlayBottom.scaleX, takedownOverlayBottom.scaleY,
    takedownOverlayBottom.rotationX, takedownOverlayBottom.rotationY)
    -- end

    -- love.graphics.draw(notificationSprite.image, notificationSprite.x, notificationSprite.y, notificationSprite.rotation, notificationSprite.scaleX, notificationSprite.scaleY,
    -- notificationSprite.rotationX, notificationSprite.rotationY)
    -- Draw notifications
    for i, notification in ipairs(notifications) do
        if notification.image then
            love.graphics.draw(notification.image, notification.x + GUIxOffset, notification.y, notification.rotation, notification.scaleX, notification.scaleY,
            notification.rotationX, notification.rotationY)
        end
    end
    for i, emphasis in ipairs(notificationEmphasis) do
        if emphasis.image then
            if exitGame == 1 then
                love.graphics.setColor(1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), emphasis.alpha)
            else
                love.graphics.setColor(1, 1, 1, emphasis.alpha)
            end
            love.graphics.draw(emphasis.image, emphasis.x + GUIxOffset, emphasis.y, emphasis.rotation, emphasis.scaleX, emphasis.scaleY,
            emphasis.rotationX, emphasis.rotationY)
            if exitGame == 1 then
                love.graphics.setColor(1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1 - (1 - actualGameSpeed), 1)
            else
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end

    if playTutorial == 1 then
        local text
        if tutorialStage == 1 then
            text = "Arrow Keys To Move!"
            love.graphics.print(text, (screenWidth / 2) - ((45 * (#text / 2)) * scaleStuff("w")) + math.random(-2, 2), (screenHeight / 3) + math.random(-2, 2))
        elseif tutorialStage == 2 then
            text = "\"a\" To Boost!"
            love.graphics.print(text, (screenWidth / 2) - ((45 * (#text / 2)) * scaleStuff("w")) + math.random(-2, 2), (screenHeight / 3) + math.random(-2, 2))
        elseif tutorialStage == 3 then
            text = "NITRO"
            love.graphics.print(text, (3 * screenWidth / 4) - ((45 * (#text / 2)) * scaleStuff("w")) + math.random(-2, 2), (screenHeight - 75) + math.random(-2, 2))
            text = "HEALTH"
            love.graphics.print(text, (screenWidth / 4) - ((45 * (#text / 2)) * scaleStuff("w")) + math.random(-2, 2), (screenHeight - 75) + math.random(-2, 2))
        elseif tutorialStage == 4 then
            text = "SURVIVE AND DESTROY"
            love.graphics.print(text, (screenWidth / 2) - ((45 * (#text / 2)) * scaleStuff("w")) + math.random(-2, 2), (screenHeight / 3) + math.random(-2, 2))
        end
    end
    love.graphics.translate(0, -GUIyOffset)
	CScreen.cease()
end

function loadSongs()
    local songs = {
        -- {path = "Sounds/song1.mp3", volume = 0.3},
        {path = "Sounds/frantic-fast-forward-trim.mp3", volume = 0.3},
        {path = "Sounds/too-much-data-trim.mp3", volume = 0.3},
        {path = "Sounds/shadowy-aberrant-realities-anthem-fade.mp3", volume = 0.3},
    }

    math.randomseed(os.time())
    shuffleTable(songs)

    for i, song in ipairs(songs) do
        soundManager:addSongToQueue(song.path, song.volume)
    end

    soundManager:playNextSong()
end

-- Fisher-Yates algorithm made by AI
function shuffleTable(t)
    local n = #t
    for i = n, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

function tutorialUpdate(dt)
    tutorialTimer = tutorialTimer - dt
    if tutorialTimer < 0 then tutorialTimer = 0 end

    -- print(tutorialTimer)

    if pressedMovementkeys == 1 and tutorialTimer <= 0 and tutorialStage == 1 then
        tutorialStage = 2
        tutorialTimer = 1
    end
    if pressedNitroKey == 1 and tutorialTimer <= 0 and tutorialStage == 2 then
        tutorialStage = 3
        tutorialTimer = 4
    end
    if tutorialStage == 3 and tutorialTimer <= 0 then
        tutorialStage = 4
        tutorialTimer = 4
    end
    if tutorialStage == 4 and tutorialTimer <= 0 then
        tutorialStage = 5
        tutorialTimer = 2
    end
    if tutorialStage == 5 and tutorialTimer <= 0 then
        playTutorial = 0
    end
end

function loadGUI()
    local scaleX = 1
    local scaleY = 1

    numberImageList = {
        love.graphics.newImage("Sprites/GUI/Numbers/0.png"),
        love.graphics.newImage("Sprites/GUI/Numbers/1.png"),
        love.graphics.newImage("Sprites/GUI/Numbers/2.png"),
        love.graphics.newImage("Sprites/GUI/Numbers/3.png"),
        love.graphics.newImage("Sprites/GUI/Numbers/4.png"),
        love.graphics.newImage("Sprites/GUI/Numbers/5.png"),
        love.graphics.newImage("Sprites/GUI/Numbers/6.png"),
        love.graphics.newImage("Sprites/GUI/Numbers/7.png"),
        love.graphics.newImage("Sprites/GUI/Numbers/8.png"),
        love.graphics.newImage("Sprites/GUI/Numbers/9.png")
    }
    nitroImageList = {
        love.graphics.newImage("Sprites/GUI/NitroBar/1.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/2.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/3.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/4.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/5.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/6.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/7.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/8.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/9.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/10.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/11.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/12.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/13.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/14.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/15.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/16.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/17.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/18.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/19.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/20.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/21.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/22.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/23.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/24.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/25.png"),
        love.graphics.newImage("Sprites/GUI/NitroBar/26.png"),
    }
    notificationImageList = {
        love.graphics.newImage("Sprites/GUI/Notifications/nearMiss.png"),
        love.graphics.newImage("Sprites/GUI/Notifications/awesomeNearMiss.png")
    }

    healthImageList = {
        love.graphics.newImage("Sprites/GUI/HealthBar/1.png"),
        love.graphics.newImage("Sprites/GUI/HealthBar/2.png"),
        love.graphics.newImage("Sprites/GUI/HealthBar/3.png"),
        love.graphics.newImage("Sprites/GUI/HealthBar/4.png"),
        love.graphics.newImage("Sprites/GUI/HealthBar/5.png"),
        love.graphics.newImage("Sprites/GUI/HealthBar/6.png"),
        love.graphics.newImage("Sprites/GUI/HealthBar/7.png"),
        love.graphics.newImage("Sprites/GUI/HealthBar/8.png"),
        love.graphics.newImage("Sprites/GUI/HealthBar/9.png"),
        love.graphics.newImage("Sprites/GUI/HealthBar/10.png"),
        love.graphics.newImage("Sprites/GUI/HealthBar/11.png"),
    }

    heatIndicatorImageList = {
        love.graphics.newImage("Sprites/GUI/HeatIndicator/0.png"),
        love.graphics.newImage("Sprites/GUI/HeatIndicator/1.png"),
        love.graphics.newImage("Sprites/GUI/HeatIndicator/2.png"),
        love.graphics.newImage("Sprites/GUI/HeatIndicator/3.png"),
        love.graphics.newImage("Sprites/GUI/HeatIndicator/4.png"),
        love.graphics.newImage("Sprites/GUI/HeatIndicator/5.png"),
    }

    -- Prepare Speed Numbers
    local numberxOffset = 25
    local numberyOffset = 150
    speedNumber1 = {
        x = screenWidth - numberImageList[1]:getWidth() - numberxOffset,
        y = screenHeight - numberyOffset,
        rotation = 0,
        rotationX = numberImageList[1]:getWidth() / 2,
        rotationY = numberImageList[1]:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = numberImageList[1]:getWidth() * scaleX,
        height = numberImageList[1]:getHeight() * scaleY,
        image = numberImageList[1],
        flag = 0,
    }
    speedNumber1.image:setFilter("nearest", "nearest")
    speedNumber2 = {
        x = screenWidth - (2 * numberImageList[1]:getWidth()) - numberxOffset,
        y = screenHeight - numberyOffset,
        rotation = 0,
        rotationX = numberImageList[1]:getWidth() / 2,
        rotationY = numberImageList[1]:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = numberImageList[1]:getWidth() * scaleX,
        height = numberImageList[1]:getHeight() * scaleY,
        image = numberImageList[1],
        flag = 0,
    }
    speedNumber2.image:setFilter("nearest", "nearest")
    speedNumber3 = {
        x = screenWidth - (3 * numberImageList[1]:getWidth()) - numberxOffset,
        y = screenHeight - numberyOffset,
        rotation = 0,
        rotationX = numberImageList[1]:getWidth() / 2,
        rotationY = numberImageList[1]:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = numberImageList[1]:getWidth() * scaleX,
        height = numberImageList[1]:getHeight() * scaleY,
        image = numberImageList[1],
        flag = 0,
    }
    speedNumber3.image:setFilter("nearest", "nearest")
    
    -- Prepare nitro bar
    local numberxOffset = 25
    local numberyOffset = 0
    nitroBar = {
        x = screenWidth - (nitroImageList[1]:getWidth()) - numberxOffset,
        y = screenHeight - numberyOffset,
        rotation = 0,
        rotationX = numberImageList[1]:getWidth() / 2,
        rotationY = numberImageList[1]:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = numberImageList[1]:getWidth() * scaleX,
        height = numberImageList[1]:getHeight() * scaleY,
        image = numberImageList[1],
        flag = 0,
    }

    -- Prepare Near Miss notifications
    local numberxOffset = 175
    local numberyOffset = 225
    notificationSprite = {
        x = screenWidth - numberxOffset,
        y = screenHeight - numberyOffset,
        xOrig = screenWidth - numberxOffset,
        yOrig = screenHeight - numberyOffset,
        scaleX = scaleX,
        scaleY = scaleY
    }
    notifications = {} -- Table to hold notification objects
    notificationEmphasis = {}

    -- Prepare takedown overlay
    takedownOverlayTopImage = love.graphics.newImage("Sprites/GUI/Notifications/takedownOverlayTop.png")
    takedownOverlayBottomImage = love.graphics.newImage("Sprites/GUI/Notifications/takedownOverlayBottom.png")

    displayGUI = 1
    local scaleX = 2
    local scaleY = 2
    local numberyOffset = 150
    takedownOverlayTop = {
        x = screenWidth / 2,
        y = numberyOffset,
        xOrig = screenWidth / 2,
        yOrig = numberyOffset,
        rotation = 0,
        rotationX = takedownOverlayTopImage:getWidth() / 2,
        rotationY = takedownOverlayTopImage:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = takedownOverlayTopImage:getWidth() * scaleX,
        height = takedownOverlayTopImage:getHeight() * scaleY,
        image = takedownOverlayTopImage,
        timer = 0,
    }
    numberyOffset = 15
    takedownOverlayBottom = {
        x = screenWidth / 2,
        y = 1080 - numberyOffset,
        xOrig = screenWidth / 2,
        yOrig = 1080 - numberyOffset,
        rotation = 0,
        rotationX = takedownOverlayBottomImage:getWidth() / 2,
        rotationY = takedownOverlayBottomImage:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = takedownOverlayBottomImage:getWidth() * scaleX,
        height = takedownOverlayBottomImage:getHeight() * scaleY,
        image = takedownOverlayBottomImage,
        timer = 0,
    }
    takedownOverlayTop.image:setFilter("nearest", "nearest")
    takedownOverlayBottom.image:setFilter("nearest", "nearest")

    -- Reset Scale
    scaleX = 1
    scaleY = 1

    -- Prepare health GUI
    local numberxOffset = 100
    local numberyOffset = 40
    healthBar = {
        x = healthImageList[11]:getWidth() - numberxOffset,
        y = screenHeight - numberyOffset,
        rotation = 0,
        rotationX = healthImageList[11]:getWidth() / 2,
        rotationY = healthImageList[11]:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = healthImageList[11]:getWidth() * scaleX,
        height = healthImageList[11]:getHeight() * scaleY,
        image = healthImageList[11],
        flag = 0,
    }

    -- Set Scale
    scaleX = 1.5
    scaleY = 1.5

    -- Prepare heat indicator
    local numberxOffset = 100
    local numberyOffset = 150
    heatIndicator = {
        x = healthBar.x,
        y = healthBar.y - numberyOffset,
        rotation = 0,
        rotationX = heatIndicatorImageList[1]:getWidth() / 2,
        rotationY = heatIndicatorImageList[1]:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = heatIndicatorImageList[1]:getWidth() * scaleX,
        height = heatIndicatorImageList[1]:getHeight() * scaleY,
        image = heatIndicatorImageList[1],
        flag = 0,
    }

    -- Set Scale
    scaleX = 0.75
    scaleY = 0.75

    local numberyOffset = 50
    heatIndicatorNumber = {
        x = heatIndicator.x,
        y = heatIndicator.y + numberyOffset,
        rotation = 0,
        rotationX = numberImageList[1]:getWidth() / 2,
        rotationY = numberImageList[1]:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = numberImageList[1]:getWidth() * scaleX,
        height = numberImageList[1]:getHeight() * scaleY,
        image = numberImageList[1],
        flag = 0,
    }
end

function updateGUI(dt)
    speedMultiplier = 0.1

    local speedStr = tostring(math.floor(carSprite.speed * speedMultiplier))

    local len = string.len(speedStr)

    -- Get the digits
    local digit1 = len >= 3 and tonumber(string.sub(speedStr, len-2, len-2)) or 0
    local digit2 = len >= 2 and tonumber(string.sub(speedStr, len-1, len-1)) or 0
    local digit3 = len >= 1 and tonumber(string.sub(speedStr, len, len)) or 0

    -- Update GUI
    speedNumber1.image = numberImageList[digit3 + 1]  -- Lua array indices start at 1
    speedNumber2.image = numberImageList[digit2 + 1]  -- Lua array indices start at 1
    speedNumber3.image = numberImageList[digit1 + 1]  -- Lua array indices start at 1

    speedNumber1.rotationX = speedNumber1.image:getWidth() / 2
    speedNumber1.rotationY = speedNumber1.image:getHeight() / 2
    speedNumber2.rotationX = speedNumber2.image:getWidth() / 2
    speedNumber2.rotationY = speedNumber2.image:getHeight() / 2
    speedNumber3.rotationX = speedNumber3.image:getWidth() / 2
    speedNumber3.rotationY = speedNumber3.image:getHeight() / 2

    -- Update nitro bar
    local nitroFraction = nitroSprite.amount / nitroSprite.maxAmount

    local nitroImageIndex = math.floor(nitroFraction * 26) + 1

    nitroImageIndex = math.max(1, math.min(nitroImageIndex, 26))

    nitroBar.image = nitroImageList[nitroImageIndex]

    -- Update health bar
    local healthFraction = carSprite.health / carSprite.maxHealth

    local healthImageIndex = math.floor(healthFraction * 11) + 1

    healthImageIndex = math.max(1, math.min(healthImageIndex, 11))
    
    if carSprite.health ~= 0 and healthImageIndex == 1 then
        healthImageIndex = 2
    end

    healthBar.image = healthImageList[healthImageIndex]

    -- Update Heat Level Indicator
    heatIndicator.image = heatIndicatorImageList[math.min((heatLevel + 1), 5)]

    heatIndicatorNumber.image = numberImageList[math.min((heatLevel + 1), 6)]
    heatIndicatorNumber.rotationX = heatIndicatorNumber.image:getWidth() / 2
    heatIndicatorNumber.rotationY = heatIndicatorNumber.image:getHeight() / 2

    -- Update each notification
    for i, notification in ipairs(notifications) do
        notification.timer = notification.timer - dt
        
        if notification.timer < 0 then
            notification.timer = 0
        end
        -- print(notification.timer)
        
        if notification.notification ~= 0 then -- we have a notification to display
            local timerChangeBy = 0
            if notification.timer == 0 and notification.displaying == 0 then -- notification just started
                if i ~= 1 then
                    notification.y = notificationSprite.yOrig - notifications[i-1].height * (i - 1)
                else
                    notification.y = notificationSprite.yOrig
                end

                timerChangeBy = 1
                local notificationImage = notificationImageList[notification.notification]
                notification.rotationX = notificationImage:getWidth() / 2
                notification.rotationY = notificationImage:getHeight()
                notification.width = notificationImage:getWidth() * notification.scaleX
                notification.height = notificationImage:getHeight() * notification.scaleY
                notification.image = notificationImage
                notification.image:setFilter("nearest", "nearest")
                
                -- Duplicate notification for emphasis
                local clonedNotification = deepcopy(notification)
                clonedNotification.alpha = 1
                table.insert(notificationEmphasis, clonedNotification)
                notification.displaying = 1
            end

            if notification.timer < 0.5 and notification.timer ~= 0 then
                notification.x = notification.x + 700 * dt
            else
                notification.x = notification.x + 200 * dt
            end
            if notification.timer == 0 and notification.displaying == 1 and timerChangeBy == 0 then
                notification.notification = 0
                notification.displaying = 0
            end

            notification.timer = notification.timer + timerChangeBy
        else
            notification.x = 5000
        end
    end

    -- Remove notifications whose timer has reached 0
    for i = #notifications, 1, -1 do
        if notifications[i].timer == 0 then
            table.remove(notifications, i)
        end
    end

    -- Emphasis Update
    for i, emphasis in ipairs(notificationEmphasis) do
        emphasis.timer = emphasis.timer - dt
        
        if emphasis.timer < 0 then
            emphasis.timer = 0
        end
        -- print(emphasis.timer)
        
        if emphasis.notification ~= 0 then -- we have a notification to display
            local timerChangeBy = 0
            if emphasis.timer == 0 and emphasis.displaying == 0 then -- notification just started
                if i ~= 1 then
                    emphasis.y = notificationSprite.yOrig - notifications[i-1].height * (i - 1)
                else
                    emphasis.y = notificationSprite.yOrig
                end

                timerChangeBy = 1
                emphasis.displaying = 1
                local notificationImage = notificationImageList[emphasis.notification]
                emphasis.rotationX = notificationImage:getWidth() / 2
                emphasis.rotationY = notificationImage:getHeight()
                emphasis.width = notificationImage:getWidth() * emphasis.scaleX
                emphasis.height = notificationImage:getHeight() * emphasis.scaleY
                emphasis.image = notificationImage
                emphasis.image:setFilter("nearest", "nearest")
            end
            
            -- Change stuff
            emphasis.scaleX = emphasis.scaleX + 0.2 * dt
            emphasis.scaleY = emphasis.scaleY + 0.2 * dt
            emphasis.alpha = emphasis.alpha - 0.5 * dt

            if emphasis.timer == 0 and emphasis.displaying == 1 and timerChangeBy == 0 then
                emphasis.notification = 0
                emphasis.displaying = 0
            end

            emphasis.timer = emphasis.timer + timerChangeBy
        else
            emphasis.x = 5000
        end
    end

    -- Remove notifications whose timer has reached 0
    for i = #notificationEmphasis, 1, -1 do
        if notificationEmphasis[i].timer == 0 then
            table.remove(notificationEmphasis, i)
        end
    end

    -- print((-takedownOverlayTop.yOrig - takedownOverlayTop.y))
    -- Update Takedown Overlay
    if takedownCameraTimer > 0 then
        takedownOverlayTop.y = takedownOverlayTop.y + (takedownOverlayTop.yOrig - takedownOverlayTop.y) * dt * 25
        takedownOverlayBottom.y = takedownOverlayBottom.y + (takedownOverlayBottom.yOrig - takedownOverlayBottom.y) * dt * 25
    else
        takedownOverlayTop.y = takedownOverlayTop.y + (-550 - takedownOverlayTop.y) * dt * 15
        takedownOverlayBottom.y = takedownOverlayBottom.y + (screenHeight + 550 - takedownOverlayBottom.y) * dt * 15
    end
    if takedownOverlayTop.y < - 500 then
        displayGUI = 1
    else
        displayGUI = 0
    end
end

function addNotification(notificationType)
    local newNotification = {
        notification = notificationType,
        timer = 0,
        displaying = 0,
        x = notificationSprite.xOrig,
        y = notificationSprite.yOrig,
        rotationX = 0,
        rotationY = 0,
        width = 0,
        height = 0,
        image = nil,
        scaleX = notificationSprite.scaleX,
        scaleY = notificationSprite.scaleY
    }
    table.insert(notifications, newNotification)
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, stuff
        copy = orig
    end
    return copy
end

function loadDebris()
    local scaleX = 0.5
    local scaleY = 0.5
    local debrisImage = love.graphics.newImage("Sprites/debris.png")
    debrisTable = {}

    debrisSprite = {
        x = 0,
        y = 0,
        velocityx = 0,
        velocityy = 0,
        rotation = 0,
        rotationX = debrisImage:getWidth() / 2,
        rotationY = debrisImage:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = debrisImage:getWidth() * scaleX,
        height = debrisImage:getHeight() * scaleY,
        image = debrisImage,
        alpha = 1,
        timer = 0
    }
end

function addDebris2(x, y, rotation, velx, vely)
    local debrisCopy = deepcopy(debrisSprite)
    debrisCopy.x = x
    debrisCopy.y = y
    debrisCopy.velocityx = velx
    debrisCopy.velocityy = vely
    debrisCopy.rotation = rotation
    table.insert(debrisTable, debrisCopy)
end

function updateDebris(dt)

    -- Update debris
    for i, debris in ipairs(debrisTable) do
        debris.timer = debris.timer - dt
        
        if debris.timer < 0 then
            debris.timer = 0
        end
        -- print(debris.timer)
        
        local timerChangeBy = 0
        if debris.timer == 0 then
            timerChangeBy = 1
        end
        
        debris.alpha = debris.alpha - 0.6 * dt
        debris.x = debris.x + debris.velocityx * dt
        debris.y = debris.y + (-roadFrameMove + debris.velocityy) * dt

        debris.velocityx = debris.velocityx * 0.995
        debris.velocityy = debris.velocityy * 0.995

        debris.timer = debris.timer + timerChangeBy
    end

    for i = #debrisTable, 1, -1 do
        if debrisTable[i].timer == 0 then
            table.remove(debrisTable, i)
        end
    end
end

function splitSpeed(speed, rotation)
    local speedx = speed * math.cos(rotation)
    local speedy = speed * math.sin(rotation)
    return speedx, speedy
end

function drawShadow(image, x, y, angle, shadowAngle, shadowDistance, scaleX, scaleY, rotationX, rotationY)
    -- Shadow offset
    local shadowOffsetX = math.cos(shadowAngle) * shadowDistance
    local shadowOffsetY = math.sin(shadowAngle) * shadowDistance

    -- Set the color to black with some transparency
    love.graphics.setColor(0, 0, 0, 0.5)

    -- Draw the shadow, offset and scaled
    love.graphics.draw(image, (x + shadowOffsetX),
    (y + shadowOffsetY), angle,
    scaleX * 0.9, scaleY * 0.9,
    rotationX * 0.9, rotationY * 0.9)

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function loadCar()
    local scaleX = 0.5
    local scaleY = 0.5
    local image = love.graphics.newImage(playerCarInfo.image)
    carSprite = {
        x = (screenWidth / 2),
        y = 1000,
        rotation = (-math.pi / 2),
        gripRotation = (-math.pi / 2),
        rotationX = (image:getWidth() / 2),
        rotationY = (image:getHeight() / 2),
        scaleX = scaleX  * playerScaleMultiplier,
        scaleY = scaleY  * playerScaleMultiplier,
        speed = 1500,
        appear = 0,
        width = (image:getWidth() * scaleX  * playerScaleMultiplier),
        height = (image:getHeight() * scaleY  * playerScaleMultiplier),
        image = image,
        prevX = 1000,
        prevY = 800,
        health = playerCarInfo.health,
        maxHealth = playerCarInfo.health,
        maxSpeed = playerCarInfo.maxSpeed,
        accel = playerCarInfo.acceleration,
        grip = playerCarInfo.grip,
        rotationSpeed = 2,
    }

    local minRotationSpeed = 1
    local maxRotationSpeed = 2

    carSprite.rotationSpeed = minRotationSpeed + (carSprite.grip / 100) * (maxRotationSpeed - minRotationSpeed)

    -- Load Nitro
    nitroImage = love.graphics.newImage("Sprites/nitro.png")
    nitroSprite = {
        x = 1000,
        y = 800,
        rotation = -math.pi/2,
        rotationX = nitroImage:getWidth() / 2,
        rotationY = nitroImage:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = nitroImage:getWidth() * scaleX,
        height = nitroImage:getHeight() * scaleY,
        image = nitroImage,
        amount = 4,
        maxAmount = 8,
        flag = 0,
        boostamount = 1500
    }

    -- Load Skid marks
    skidMarkImage = love.graphics.newImage("Sprites/skidmark.png")
    skidMarkSprite = {
        horizontalOffset = 0,
        verticalOffset = 0,
        horizontalOffsetI = 40,
        verticalOffsetI = 30,
        rotation = (-math.pi / 2),
        scaleX = 1.5,
        scaleY = 1,
        rotationX = skidMarkImage:getWidth(),
        rotationY = skidMarkImage:getHeight() / 2,
        alpha = 1,
    }

    -- polygon collider for the car
    carCollider = HC.polygon(
        carSprite.x, carSprite.y,
        carSprite.x + carSprite.width - 10, carSprite.y,
        carSprite.x + carSprite.width - 10, carSprite.y + carSprite.height - 10,
        carSprite.x, carSprite.y + carSprite.height - 10
    )
    table.insert(colliders, carCollider)
    local xOffset = carSprite.height * 0.9
    local yOffset = 25
    carFrontCollider = HC.polygon(
        carSprite.x, carSprite.y + xOffset,
        carSprite.x + yOffset, carSprite.y + xOffset,
        carSprite.x + yOffset, carSprite.y + carSprite.height - xOffset,
        carSprite.x, carSprite.y + carSprite.height - xOffset
    )
    table.insert(colliders, carCollider)
end

function getWheelPositions()
    local halfWidth = carSprite.width / 2
    local halfHeight = carSprite.height / 2
    
    local offsetX = halfWidth - skidMarkSprite.horizontalOffsetI
    local offsetY = halfHeight - skidMarkSprite.verticalOffsetI
    
    local cosRot = math.cos(carSprite.rotation)
    local sinRot = math.sin(carSprite.rotation)
    
    local topLeftX = carSprite.x + (-offsetX * cosRot - -offsetY * sinRot)
    local topLeftY = carSprite.y + (-offsetX * sinRot + -offsetY * cosRot)
    
    local topRightX = carSprite.x + (offsetX * cosRot - -offsetY * sinRot)
    local topRightY = carSprite.y + (offsetX * sinRot + -offsetY * cosRot)
    
    local bottomLeftX = carSprite.x + (-offsetX * cosRot - offsetY * sinRot)
    local bottomLeftY = carSprite.y + (-offsetX * sinRot + offsetY * cosRot)
    
    local bottomRightX = carSprite.x + (offsetX * cosRot - offsetY * sinRot)
    local bottomRightY = carSprite.y + (offsetX * sinRot + offsetY * cosRot)
    
    return {
        {x = topLeftX, y = topLeftY},
        {x = topRightX, y = topRightY},
        {x = bottomLeftX, y = bottomLeftY},
        {x = bottomRightX, y = bottomRightY}
    }
end

function drawSkidMarks()
    local wheelPositions = getWheelPositions(carSprite)
    skidMarkSprite.rotation = carSprite.gripRotation

    local rotationDifference = math.abs(carSprite.rotation - carSprite.gripRotation)
    rotationDifference = rotationDifference % (2 * math.pi)
    if rotationDifference > math.pi then
        rotationDifference = 2 * math.pi - rotationDifference
    end
    
    skidMarkSprite.alpha = rotationDifference / (math.pi / 4)
    
    love.graphics.setColor(1, 1, 1, skidMarkSprite.alpha)

    for _, pos in ipairs(wheelPositions) do
        love.graphics.draw(skidMarkImage, math.floor(pos.x), math.floor(pos.y), skidMarkSprite.rotation,
        skidMarkSprite.scaleX, skidMarkSprite.scaleY, skidMarkSprite.rotationX, skidMarkSprite.rotationY)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function playerUpdate(dt)
    if love.keyboard.isDown('right') then -- Turning
        carSprite.rotation = carSprite.rotation + carSprite.rotationSpeed * dt
        pressedMovementkeys = 1
    elseif love.keyboard.isDown('left') then
        carSprite.rotation = carSprite.rotation - carSprite.rotationSpeed * dt
        pressedMovementkeys = 1
    end
    -- if love.keyboard.isDown('up') then -- Moving
        -- pressedMovementkeys = 1
    if love.keyboard.isDown('down') then
        carSprite.speed = carSprite.speed - carSprite.accel * 1.5 * dt
        camerayShake = camerayShake + carSprite.accel / 5 * carSprite.speed / 1000
    else
        carSprite.speed = carSprite.speed + carSprite.accel * dt -- Accel forward
        camerayShake = camerayShake - carSprite.accel / 5 * carSprite.speed / 1000
    end
    if love.keyboard.isDown('a') and nitroSprite.amount > 0 then -- Nitro
        carSprite.speed = carSprite.speed + nitroSprite.boostamount * dt
        camerayShake = camerayShake - nitroSprite.boostamount / 7.5 * carSprite.speed / 1000
        nitroSprite.appear = 1
        nitroSprite.amount = nitroSprite.amount - dt
        carSprite.maxSpeed = playerCarInfo.maxSpeed + 1000
        pressedNitroKey = 1
    else
        nitroSprite.appear = 0
        carSprite.maxSpeed = playerCarInfo.maxSpeed
    end
    -- print(nitroSprite.amount)

    if love.keyboard.isDown('a') and nitroSprite.amount > 0 and love.keyboard.isDown('up') then
        minCamerayShake = -150
    else
        minCamerayShake = -100
    end

    if nitroSprite.amount < 0 then
        nitroSprite.amount = 0
    elseif nitroSprite.amount > nitroSprite.maxAmount then
        nitroSprite.amount = nitroSprite.maxAmount
    end
    
    if carSprite.rotation < -math.rad(180) then carSprite.rotation = -math.rad(180) end
    if carSprite.rotation > math.rad(0) then carSprite.rotation = math.rad(0) end

    -- print(math.deg(carSprite.rotation))

    local maxGripValue = 500
    local gripFactor = carSprite.grip / maxGripValue
    local rotationDifference = carSprite.rotation - carSprite.gripRotation
    carSprite.gripRotation = carSprite.gripRotation + rotationDifference * gripFactor

    local dx = carSprite.speed * math.cos(carSprite.gripRotation)
    roadFrameMove = carSprite.speed * math.sin(carSprite.gripRotation)
    carSprite.x = carSprite.x + dx * dt

    distanceTraveled = distanceTraveled - roadFrameMove * dt
    -- print(distanceTraveled)
    
    -- Update collider position and rotation
    carCollider:moveTo(carSprite.x, carSprite.y)
    carCollider:rotate(carSprite.rotation - carCollider:rotation(), carCollider:center())

    local carFrontX = carSprite.x + carSprite.height * math.cos(carSprite.rotation)
    local carFrontY = carSprite.y + carSprite.height * math.sin(carSprite.rotation)

    carFrontCollider:moveTo(carFrontX, carFrontY)
    carFrontCollider:rotate(carSprite.rotation - carFrontCollider:rotation(), carFrontCollider:center())
    table.insert(colliders, carCollider)
    table.insert(colliders, carFrontCollider)
    
    -- Nitro Movement
    local carEndX = carSprite.x - carSprite.height * math.cos(carSprite.rotation)
    local carEndY = carSprite.y - carSprite.height * math.sin(carSprite.rotation)

    nitroSprite.x = carEndX + math.random(-3, 3)
    nitroSprite.y = carEndY + math.random(-3, 3)
    nitroSprite.rotation = carSprite.rotation

    -- Max Speed
    carSprite.speed = carSprite.speed * 0.999
    if carSprite.speed > carSprite.maxSpeed then
        carSprite.speed = carSprite.speed * 0.97
    end

    -- Update player camera
    cameraUpdate(dt)

    if carSprite.health <= 0 then
        print("Player Died")
        exitGame = 1
        gameSpeed = 0
        -- love.audio.stop() -- Stop all current sounds
        -- carSprite.health = 30
    end
end
-- CHECKPOINT THING MY CODE IS SO LONG..

function cameraUpdate(dt)
    takedownCameraTimer = takedownCameraTimer - dt

    if takedownCameraTimer < 0 then
        takedownCameraTimer = 0
    end

    if takedownCamera == 1 then
        takedownCameraTimer = 0.6
        takedownCamera = 0
    end

    local cameraxOffset = (policeSprite.x - carSprite.x) / 2
    local camerayOffset1 = (policeSprite.y - carSprite.y) / 2

    if camerayShake > 100 then
        camerayShake = 100
    elseif camerayShake < minCamerayShake then
        camerayShake = minCamerayShake
    end

    local dx = 0
    local dy = 0
    -- Calculate the distance to the player
    if takedownCameraTimer > 0 then
        dx = carSprite.x - camera.x + cameraxOffset - cameraxScaleOffset
        dy = carSprite.y - camera.y - camerayShake + camerayOffset1
    else
        dx = carSprite.x - camera.x - cameraxScaleOffset
        dy = carSprite.y - camera.y - camerayOffset - camerayShake
    end
    camerayShake = camerayShake * 0.9

    local lerpFactor = 2 -- camera speed
    camera:move(dx * lerpFactor * dt + math.random(-2, 2), dy * lerpFactor * dt + math.random(-2, 2))
end

function loadTraffic()
    trafficImage = love.graphics.newImage("Sprites/Cars/yellowcar.png")
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
        velocityx = 0,
        nmtimer = 0,
        hittimer = 0,
        warningOffset = 700,
        nitro = 1
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
        velocityx = 0,
        nmtimer = 0,
        hittimer = 0,
        warningOffset = 700,
        nitro = 1
    }

    -- polygon colliders for the traffic
    trafficRightCollider = HC.polygon(
        trafficRight.x, trafficRight.y,
        trafficRight.x + trafficRight.width - 10, trafficRight.y,
        trafficRight.x + trafficRight.width - 10, trafficRight.y + trafficRight.height - 10,
        trafficRight.x, trafficRight.y + trafficRight.height - 10
    )
    trafficLeftCollider = HC.polygon(
        trafficLeft.x, trafficLeft.y,
        trafficLeft.x + trafficLeft.width - 10, trafficLeft.y,
        trafficLeft.x + trafficLeft.width - 10, trafficLeft.y + trafficLeft.height - 10,
        trafficLeft.x, trafficLeft.y + trafficLeft.height - 10
    )
    local nearMissColliderHeightOffset = 10
    local nearMissColliderWidthOffset = 150
    local awesomeMissColliderWidthOffset = 40

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
    trafficLeft.hittimer = trafficLeft.hittimer - dt
    trafficRight.nmtimer = trafficRight.nmtimer - dt
    trafficLeft.nmtimer = trafficLeft.nmtimer - dt
    trafficRight.hittimer = trafficRight.hittimer - dt

    if trafficRight.nmtimer < 0 then trafficRight.nmtimer = 0 end -- While debugging I found I could do this!
    if trafficLeft.nmtimer < 0 then trafficLeft.nmtimer = 0 end -- I am not going around and changing the other ones ..
    if trafficRight.timer < 0 then trafficRight.timer = 0 end
    if trafficLeft.timer < 0 then trafficLeft.timer = 0 end
    if trafficRight.hittimer < 0 then trafficRight.hittimer = 0 end
    if trafficLeft.hittimer < 0 then trafficLeft.hittimer = 0 end

    if trafficRight.timer < 1 and trafficRight.timer > 0 then
        trafficRight.image = trafficWarning
    end
    if trafficLeft.timer < 1 and trafficLeft.timer > 0 then
        trafficLeft.image = trafficWarning
    end

    trafficRight.rotationX = trafficRight.image:getWidth() / 2
    trafficRight.rotationY = trafficRight.image:getHeight() / 2
    trafficLeft.rotationX = trafficLeft.image:getWidth() / 2
    trafficLeft.rotationY = trafficLeft.image:getHeight() / 2

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

    if trafficRight.y > 1080 + 500 then -- Below Screen
        trafficRight.timer = math.random(1.5, 4)
        trafficRight.y = -500
        trafficRight.x = math.random(1500, 2000)
        trafficRight.crashed = 0
        trafficRight.rotation = -math.rad(90)
        trafficRight.nitro = 1
    end

    if trafficLeft.y > 1080 + 500 then
        trafficLeft.timer = math.random(1.5, 4)
        trafficLeft.y = -500
        trafficLeft.x = math.random(-100, 500)
        trafficLeft.crashed = 0
        trafficLeft.rotation = -math.rad(90)
        trafficLeft.nitro = 1
    end

    -- Ensure traffic stays within the screen bounds
    if trafficRight.y < -1080 then
        trafficRight.y = -1080
    end

    if trafficLeft.y < -1080 then
        trafficLeft.y = -1080
    end

    if trafficRight.crashed == 1 then -- Crashed obv
        trafficRight.x = trafficRight.x + trafficRight.velocityx * dt
        trafficRight.rotation = trafficRight.rotation + math.rad(45) * dt
        trafficRight.y = trafficRight.y - trafficRight.velocity * dt
    end
    if trafficLeft.crashed == 1 then
        trafficLeft.x = trafficLeft.x - trafficLeft.velocityx * dt
        trafficLeft.rotation = trafficLeft.rotation + math.rad(45) * dt
        trafficLeft.y = trafficLeft.y - trafficLeft.velocity * dt
    end

    if trafficRight.nmtimer == 0 then
        if trafficRight.flag == 2 then
            print("Awesome near miss")
            addNotification(2)
            nitroSprite.amount = nitroSprite.amount + 3
            trafficRight.flag = 0
            awesomeNearMisses = awesomeNearMisses + 1
        elseif trafficRight.flag == 1 then
            print("Near miss")
            addNotification(1)
            nitroSprite.amount = nitroSprite.amount + 2
            trafficRight.flag = 0
            nearMisses = nearMisses + 1
        end
    end
    if trafficLeft.nmtimer == 0 then
        if trafficLeft.flag == 2 then
            print("Awesome near miss")
            addNotification(2)
            nitroSprite.amount = nitroSprite.amount + 3
            trafficLeft.flag = 0
            awesomeNearMisses = awesomeNearMisses + 1
        elseif trafficLeft.flag == 1 then
            print("Near miss")
            addNotification(1)
            nitroSprite.amount = nitroSprite.amount + 2
            trafficLeft.flag = 0
            nearMisses = nearMisses + 1
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
    elseif carCollider:collidesWith(trafficLeftNearMissCollider) and trafficLeft.crashed == 0 and trafficLeft.flag ~= 2 then
        trafficLeft.flag = 1
        trafficLeft.nmtimer = 0.05
    end

    -- Deal with collisions
    if carCollider:collidesWith(trafficRightCollider) and trafficRight.hittimer == 0 then
        carSprite.speed = carSprite.speed - 350
        if takedownCameraTimer == 0 then
            carSprite.health = carSprite.health - 1 * math.floor((carSprite.speed / 1000) + 0.5)
        end 
        if (carSprite.x - trafficRight.x) < 0 then -- Right
            trafficRight.velocityx = trafficRight.velocityx + 100 * (carSprite.speed / 1000) * math.abs(carSprite.x - trafficRight.x) / 100
        else -- Left
            trafficRight.velocityx = trafficRight.velocityx - 100 * (carSprite.speed / 1000) * math.abs(carSprite.x - trafficRight.x) / 100
        end
        if trafficRight.nitro == 1 then
            nitroSprite.amount = nitroSprite.amount + 0.5
            trafficRight.nitro = 0
        end

        trafficRight.hittimer = 0.1

        for i = 1, math.floor(math.random(3,5)) do
            local velx, vely = splitSpeed(carSprite.speed, carSprite.rotation)
            addDebris2(carSprite.x + math.random(-50, 50), carSprite.y + math.random(-50, 50), carSprite.rotation + math.random(-0.2, 0.2), velx, vely)
        end
        camerayShake = camerayShake + 1000
        trafficRight.crashed = 1
        if carFrontCollider:collidesWith(trafficRightCollider) then
            trafficRight.y = carSprite.y - 275
            if takedownCameraTimer == 0 then
                carSprite.health = carSprite.health - 1
            end
        end
        trafficRight.velocity = carSprite.speed * 1.5
        trafficRight.flag = 0
    elseif carCollider:collidesWith(trafficLeftCollider) and trafficLeft.hittimer == 0 then
        carSprite.speed = carSprite.speed - 350
        if takedownCameraTimer == 0 then
            carSprite.health = carSprite.health - 1 * math.floor((carSprite.speed / 2000) + 0.5)
        end
        if (carSprite.x - trafficLeft.x) > 0 then -- Right
            trafficLeft.velocityx = trafficLeft.velocityx + 100 * (carSprite.speed / 2000) * math.abs(carSprite.x - trafficLeft.x) / 100
        else -- Left
            trafficLeft.velocityx = trafficLeft.velocityx - 100 * (carSprite.speed / 2000) * math.abs(carSprite.x - trafficLeft.x) / 100
        end
        if trafficLeft.nitro == 1 then
            nitroSprite.amount = nitroSprite.amount + 0.5
            trafficLeft.nitro = 0
        end

        trafficLeft.hittimer = 0.1

        for i = 1, math.floor(math.random(3,5)) do
            local velx, vely = splitSpeed(carSprite.speed, carSprite.rotation)
            addDebris2(carSprite.x + math.random(-50, 50), carSprite.y + math.random(-50, 50), carSprite.rotation + math.random(-0.2, 0.2), velx, vely)
        end
        camerayShake = camerayShake + 1000
        trafficLeft.crashed = 1
        if carFrontCollider:collidesWith(trafficLeftCollider) then
            trafficLeft.y = carSprite.y - 275
            if takedownCameraTimer == 0 then
                carSprite.health = carSprite.health - 1
            end
        end
        trafficLeft.velocity = carSprite.speed * 1.5
        trafficLeft.flag = 0
    end

    -- Deal with police collisions
    if policeCollider:collidesWith(trafficRightCollider) and trafficRight.timer == 0 and policeSprite.hittimer1 <= 1 then
        policeSprite.speed = policeSprite.speed * 0.75
        trafficRight.crashed = 1
        if policeSprite.crashed == 0 then
            policeSprite.health = 0
        end
        policeSprite.crashed = 1
        trafficRight.y = policeSprite.y - 275
        trafficRight.velocity = policeSprite.speed * 1.5
        trafficRight.flag = 0
    elseif policeCollider:collidesWith(trafficLeftCollider) and trafficLeft.timer == 0 and policeSprite.hittimer1 <= 1 then
        policeSprite.speed = policeSprite.speed * 0.75
        trafficLeft.crashed = 1
        if policeSprite.crashed == 0 then
            policeSprite.health = 0
        end
        policeSprite.crashed = 1
        trafficLeft.y = policeSprite.y - 275
        trafficLeft.velocity = policeSprite.speed * 1.5
        trafficLeft.flag = 0
    end

    trafficRight.velocity = trafficRight.velocity * 0.98
    trafficLeft.velocity = trafficLeft.velocity * 0.98
end

function loadEMP()
    EMPImageList = {
        love.graphics.newImage("Sprites/EMP/1.png"),
        love.graphics.newImage("Sprites/EMP/2.png"),
        love.graphics.newImage("Sprites/EMP/3.png"),
        love.graphics.newImage("Sprites/EMP/4.png"),
        love.graphics.newImage("Sprites/EMP/5.png")
    }

    scaleX = 1
    scaleY = 1

    EMPSprite = {
        x = 1000,
        y = 0,
        rotation = 0,
        rotationX = EMPImageList[1]:getWidth() / 2,
        rotationY = EMPImageList[1]:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = EMPImageList[1]:getWidth() * scaleX,
        height = EMPImageList[1]:getHeight() * scaleY,
        image = EMPImageList[1],
        visible = 0,
        timer = 0,
        spawnTimer = 0,
        flag = 8,
        speed = 350,
        duration = 7,
        alpha = 1,
    }

    EMPCollider = HC.polygon(
        EMPSprite.x, EMPSprite.y,
        EMPSprite.x + EMPSprite.width / 3, EMPSprite.y,
        EMPSprite.x + EMPSprite.width / 3, EMPSprite.y + EMPSprite.height / 3,
        EMPSprite.x, EMPSprite.y + EMPSprite.height / 3
    )
    table.insert(colliders, EMPCollider)

    EMPCopies = {} -- Table for the copies
end

function updateEMP(dt)
    EMPSprite.timer = EMPSprite.timer - dt
    EMPSprite.spawnTimer = EMPSprite.spawnTimer - dt

    if EMPSprite.timer < 0 then
        EMPSprite.timer = 0
    end
    
    if EMPSprite.spawnTimer < 0 then
        EMPSprite.spawnTimer = 0
    end
    
    if EMPSprite.visible == 0 and EMPSprite.timer == 0 and EMPSprite.spawnTimer == 0 and takedownCameraTimer == 0 and heatLevel >= 3 then -- EMP needs to spawn / appear
        EMPSprite.timer = EMPSprite.duration
        EMPSprite.visible = 1
        EMPSprite.flag = 0
    end
    -- print(EMPSprite.flag)

    -- Update position
    EMPSprite.y = carSprite.y
    if (EMPSprite.x - carSprite.x) < 0 and EMPSprite.visible == 1 then -- Move right
        if math.abs(EMPSprite.x - carSprite.x) < 20 then
            EMPSprite.x = EMPSprite.x + 10 * dt
        else
            EMPSprite.x = EMPSprite.x + EMPSprite.speed * dt
        end
    elseif EMPSprite.visible == 1 then -- Move left
        if math.abs(EMPSprite.x - carSprite.x) < 20 then
            EMPSprite.x = EMPSprite.x - 10 * dt
        else
            EMPSprite.x = EMPSprite.x - EMPSprite.speed * dt
        end
    end

    -- Update image and create clones
    local percentage = EMPSprite.timer / EMPSprite.duration
    local newFlag = nil

    if percentage < (1/5) then
        newFlag = 5
    elseif percentage < (2/5) then
        newFlag = 4
    elseif percentage < (3/5) then
        newFlag = 3
    elseif percentage < (4/5) then
        newFlag = 2
    else
        newFlag = 1
    end

    if newFlag and EMPSprite.flag ~= newFlag and EMPSprite.visible == 1 then
        EMPSprite.image = EMPImageList[newFlag]
        EMPSprite.rotationX = EMPSprite.image:getWidth() / 2
        EMPSprite.rotationY = EMPSprite.image:getHeight() / 2
        EMPSprite.width = EMPSprite.image:getWidth() * EMPSprite.scaleX
        table.insert(EMPCopies, deepcopy(EMPSprite))
        EMPSprite.flag = newFlag
    end

    -- Update collider
    EMPCollider:moveTo(EMPSprite.x, EMPSprite.y)
    EMPCollider:rotate(EMPSprite.rotation - EMPCollider:rotation(), EMPCollider:center())
    table.insert(colliders, EMPCollider)
    
    -- Deal with collisions
    if carCollider:collidesWith(EMPCollider) and EMPSprite.timer == 0 and EMPSprite.visible == 1 then --and trafficRight.crashed == 0 then
        carSprite.speed = carSprite.speed - 400
        if takedownCameraTimer == 0 then
            carSprite.health = carSprite.health - 1 * math.floor((carSprite.speed / 1000) + 0.5)
            EMPSprite.visible = 0
            EMPSprite.spawnTimer = math.random(1, 1.5)
        end
        
        for i = 1, math.floor(math.random(3,5)) do
            local velx, vely = splitSpeed(carSprite.speed, carSprite.rotation)
            addDebris2(carSprite.x + math.random(-50, 50), carSprite.y + math.random(-50, 50), carSprite.rotation + math.random(-0.2, 0.2), velx, vely)
        end
        camerayShake = camerayShake + 1000
    end

    if EMPSprite.timer == 0 and EMPSprite.visible == 1 then
        EMPSprite.visible = 0
        EMPSprite.spawnTimer = math.random(1, 1.5)
        EMPDodges = EMPDodges + 1
    end
    
    -- Update EMP copies
    for i = #EMPCopies, 1, -1 do
        local EMPcopy = EMPCopies[i]
        EMPcopy.scaleX = EMPcopy.scaleX + dt
        EMPcopy.scaleY = EMPcopy.scaleY + dt
        EMPcopy.alpha = EMPcopy.alpha - dt

        if EMPcopy.alpha <= 0 then
            table.remove(EMPCopies, i)
        else
            EMPcopy.width = EMPcopy.image:getWidth() * EMPcopy.scaleX
            EMPcopy.height = EMPcopy.image:getHeight() * EMPcopy.scaleY
            EMPcopy.x = EMPSprite.x
            EMPcopy.y = EMPSprite.y
        end
    end

    if EMPSprite.visible == 0 and EMPSprite.flag ~= 8 then
        if EMPSprite.flag ~= 6 then
            table.insert(EMPCopies, deepcopy(EMPSprite))
            EMPSprite.flag = 6
        end
        EMPSprite.image = EMPImageList[1]
        EMPSprite.rotationX = EMPImageList[1]:getWidth() / 2
        EMPSprite.rotationY = EMPImageList[1]:getHeight() / 2
        EMPSprite.width = EMPImageList[1]:getWidth() * EMPSprite.scaleX
    end

    -- if EMPSprite.flag == 8 then -- Game just started
    --     EMPSprite.flag = 0
    -- end
end

function loadSpikestrip()
    spikestripImageList = {
        love.graphics.newImage("Sprites/Spikestrip/1.png"),
        love.graphics.newImage("Sprites/Spikestrip/2.png"),
        love.graphics.newImage("Sprites/Spikestrip/3.png"),
        love.graphics.newImage("Sprites/Spikestrip/4.png"),
        love.graphics.newImage("Sprites/Spikestrip/5.png"),
    }
    
    scaleX = 1
    scaleY = 1
    
    spikestripSprite = {
        x = 0,
        y = 0,
        rotation = 0,
        rotationX = spikestripImageList[1]:getWidth() / 2,
        rotationY = spikestripImageList[1]:getHeight() / 2,
        scaleX = scaleX,
        scaleY = scaleY,
        width = spikestripImageList[1]:getWidth() * scaleX,
        height = spikestripImageList[1]:getHeight() * scaleY,
        image = spikestripImageList[1],
        visible = 0,
        timer = 0,
        spawnTimer = 0,
        flag = 0,
        speed = 0,
    }

    spikestripCollider = HC.polygon(
        policeSprite.x, policeSprite.y,
        policeSprite.x + spikestripImageList[5]:getWidth(), policeSprite.y,
        policeSprite.x + spikestripImageList[5]:getWidth(), policeSprite.y + spikestripImageList[5]:getHeight(),
        policeSprite.x, policeSprite.y + spikestripImageList[5]:getHeight()
    )
    table.insert(colliders, spikestripCollider)
end

function updateSpikestrip(dt)
    spikestripSprite.timer = spikestripSprite.timer - dt
    spikestripSprite.spawnTimer = spikestripSprite.spawnTimer - dt

    if spikestripSprite.timer < 0 then
        spikestripSprite.timer = 0
    end

    if spikestripSprite.spawnTimer < 0 then
        spikestripSprite.spawnTimer = 0
    end

    if spikestripSprite.visible == 0 and spikestripSprite.timer == 0 and spikestripSprite.spawnTimer == 0 and policeSprite.crashed == 0 and heatLevel >= 1 then -- Spikestrip needs to be spawned
        spikestripSprite.timer = 2
        spikestripSprite.visible = 1
    end

    if spikestripSprite.visible == 1 and spikestripSprite.timer > 0.75 then
        local carEndX = policeSprite.x - (policeSprite.height + 25) * math.cos(policeSprite.rotation)
        local carEndY = policeSprite.y - (policeSprite.height + 25) * math.sin(policeSprite.rotation)

        spikestripSprite.x = carEndX
        spikestripSprite.y = carEndY
        spikestripSprite.speed = carSprite.speed
    end

    if spikestripSprite.visible == 1 and spikestripSprite.timer < 0.75 then
        -- spikestripSprite.y = spikestripSprite.y - roadFrameMove * dt
        spikestripSprite.y = spikestripSprite.y - roadFrameMove * dt * math.min(math.abs(1 - (spikestripSprite.speed/2000)), 1)
    end

    spikestripSprite.speed = spikestripSprite.speed * 0.96

    if spikestripSprite.y > 1080 + 500 then
        spikestripSprite.visible = 0
        spikestripSprite.timer = 0
    end

    -- if spikestripSprite.timer <= 0 then
    --     spikestripSprite.visible = 0
    -- end
    -- print(spikestripSprite.timer)

    -- Update collider
    spikestripCollider = HC.polygon(
        policeSprite.x, policeSprite.y,
        policeSprite.x + spikestripSprite.image:getWidth(), policeSprite.y,
        policeSprite.x + spikestripSprite.image:getWidth(), policeSprite.y + spikestripSprite.image:getHeight(),
        policeSprite.x, policeSprite.y + spikestripSprite.image:getHeight()
    )
    spikestripCollider:moveTo(spikestripSprite.x, spikestripSprite.y)
    spikestripCollider:rotate(spikestripSprite.rotation - spikestripCollider:rotation(), spikestripCollider:center())
    table.insert(colliders, spikestripCollider)

    -- Deal with collisions
    if carCollider:collidesWith(spikestripCollider) and spikestripSprite.timer < 0.75 and spikestripSprite.visible == 1 then
        carSprite.speed = carSprite.speed - 500
        if takedownCameraTimer == 0 then
            carSprite.health = carSprite.health - 1 * math.floor((carSprite.speed / 2000) + 0.5)
        end
        spikestripSprite.timer = 0
        spikestripSprite.spawnTimer = math.random(2, 3)
        spikestripSprite.visible = 0

        for i = 1, math.floor(math.random(3,5)) do
            local velx, vely = splitSpeed(carSprite.speed, carSprite.rotation)
            addDebris2(carSprite.x + math.random(-50, 50), carSprite.y + math.random(-50, 50), carSprite.rotation + math.random(-0.2, 0.2), velx, vely)
        end
        camerayShake = camerayShake + 1000
    end

    -- Spikestrip animation
    if spikestripSprite.timer < 0.75 and spikestripSprite.timer > 0.65 then
        spikestripSprite.image = spikestripImageList[2]
        spikestripSprite.rotationX = spikestripImageList[2]:getWidth() / 2
        spikestripSprite.rotationY = spikestripImageList[2]:getHeight() / 2
        spikestripSprite.width = spikestripImageList[2]:getWidth() * spikestripSprite.scaleX
    elseif spikestripSprite.timer < 0.65 and spikestripSprite.timer > 0.55 then
        spikestripSprite.image = spikestripImageList[3]
        spikestripSprite.rotationX = spikestripImageList[3]:getWidth() / 2
        spikestripSprite.rotationY = spikestripImageList[3]:getHeight() / 2
        spikestripSprite.width = spikestripImageList[2]:getWidth() * spikestripSprite.scaleX
    elseif spikestripSprite.timer < 0.55 and spikestripSprite.timer > 0.45 then
        spikestripSprite.image = spikestripImageList[4]
        spikestripSprite.rotationX = spikestripImageList[4]:getWidth() / 2
        spikestripSprite.rotationY = spikestripImageList[4]:getHeight() / 2
        spikestripSprite.width = spikestripImageList[2]:getWidth() * spikestripSprite.scaleX
    elseif spikestripSprite.timer < 0.45 then
        spikestripSprite.image = spikestripImageList[5]
        spikestripSprite.rotationX = spikestripImageList[5]:getWidth() / 2
        spikestripSprite.rotationY = spikestripImageList[5]:getHeight() / 2
        spikestripSprite.width = spikestripImageList[2]:getWidth() * spikestripSprite.scaleX
    end

    if spikestripSprite.visible == 0 then
        spikestripSprite.image = spikestripImageList[1]
        spikestripSprite.rotationX = spikestripImageList[1]:getWidth() / 2
        spikestripSprite.rotationY = spikestripImageList[1]:getHeight() / 2
        spikestripSprite.width = spikestripImageList[1]:getWidth() * spikestripSprite.scaleX
    end
end

function loadPolice()
    local policeImage = love.graphics.newImage("Sprites/Cars/PoliceAnim/police c7.png")

    heatLevel = 0

    scaleX = 0.5
    scaleY = 0.5
    policeHeat = 0
    policeSprite = {
        x = 1000,
        y = 500,
        rotation = -math.pi/2,
        rotationX = policeImage:getWidth() / 2,
        rotationY = policeImage:getHeight() / 2,
        scaleX = scaleX * playerScaleMultiplier,
        scaleY = scaleY * playerScaleMultiplier,
        speed = 1600,
        acc = 200,
        width = policeImage:getWidth() * scaleX * playerScaleMultiplier,
        height = policeImage:getHeight() * scaleY * playerScaleMultiplier,
        image = policeImage,
        timer = 1,
        flag = 0,
        crashed = 0,
        velocityx = 0,
        velocityy = 0,
        prevX = 1000,
        prevY = 2200,
        health = 8,
        hittimer = 0,
        hittimer1 = 0
    }

    -- polygon colliders for the police
    policeCollider = HC.polygon(
        policeSprite.x, policeSprite.y,
        policeSprite.x + policeSprite.width, policeSprite.y,
        policeSprite.x + policeSprite.width, policeSprite.y + policeSprite.height,
        policeSprite.x, policeSprite.y + policeSprite.height
    )
end

function updatePoliceCarAnimation1(dt)
    policeAnimTimer = policeAnimTimer + dt
    
    if policeAnimTimer >= timePerFrame then
        policeAnimTimer = policeAnimTimer - timePerFrame
        currentFrame = currentFrame + 1

        if currentFrame > #policeAnimationSequence then
            currentFrame = 1
        end
    end
    if policeSprite.crashed == 0 then
        policeSprite.image = policeAnimationSequence[currentFrame]
    else
        policeSprite.image = policeAnimationSequence[2]
    end
end

function updatePolice(dt)
    updatePoliceCarAnimation1(dt)
    policeSprite.timer = policeSprite.timer - dt
    policeSprite.hittimer = policeSprite.hittimer - dt
    policeSprite.hittimer1 = policeSprite.hittimer1 + dt

    if policeSprite.timer < 0 then
        policeSprite.timer = 0
    end
    if policeSprite.hittimer < 0 then
        policeSprite.hittimer = 0
    end
    if policeSprite.hittimer1 < 0 then
        policeSprite.hittimer1 = 0
    end

    policeTakedowns = heatLevel

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
        elseif policeSprite.speed > playerCarInfo.maxSpeed then
            policeSprite.speed = playerCarInfo.maxSpeed
        end

        policeSprite.rotation = math.max(math.min(policeSprite.rotation, -math.pi/3), -2*math.pi/3)

        local dx = policeSprite.speed * math.cos(policeSprite.rotation)
        local dy = policeSprite.speed * math.sin(policeSprite.rotation)
        policeSprite.x = policeSprite.x + dx * dt
        policeSprite.y = policeSprite.y + (-roadFrameMove + dy) * dt
    elseif policeSprite.crashed == 1 then
        policeSprite.y = policeSprite.y + -roadFrameMove * dt
        policeSprite.x = policeSprite.x + policeSprite.velocityx * dt
        policeSprite.rotation = policeSprite.rotation + math.rad(45) * dt
        policeSprite.y = policeSprite.y - policeSprite.velocityy * dt
    end
    
    if policeSprite.y > 1080 + 750 then
        policeSprite.timer = math.random(1, 3)
        policeSprite.y = -500
        policeSprite.x = math.random(750, 1500)
        policeSprite.crashed = 0
        policeSprite.health = 8
        policeSprite.rotation = -math.rad(90)
        policeSprite.speed = carSprite.speed
    elseif policeSprite.y < -1080 then
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

    if policeSprite.health <= 0 then
        policeSprite.crashed = 1
        if policeSprite.health <= -300 then
            if policeDeathDustNum <= 0 then
                local velx, vely = splitSpeed(policeSprite.speed, policeSprite.rotation)
                velx = velx / 100
                for i = 1, math.floor(math.random(1, 2)) do
                    addDebris2(policeSprite.x + math.random(-50, 50), policeSprite.y + math.random(-50, 50), policeSprite.rotation + math.random(-0.2, 0.2), velx, vely)
                end
                policeDeathDustNum = math.random(0.2, 0.75)
            end
        else
            heatLevel = heatLevel + 1
            -- print(heatLevel)

            policeSprite.health = -300
            nitroSprite.amount = nitroSprite.amount + 1
            takedownCamera = 1
            local velx, vely = splitSpeed(policeSprite.speed, policeSprite.rotation)
            velx = velx / 100
            for i = 1, math.floor(math.random(4,6)) do
                addDebris2(policeSprite.x + math.random(-50, 50), policeSprite.y + math.random(-50, 50), policeSprite.rotation + math.random(-0.2, 0.2), velx, vely)
            end
            policeDeathDustNum = math.random(0.1, 0.3)
        end
        policeDeathDustNum = policeDeathDustNum - dt
    end

    -- Deal with collisions
    if carCollider:collidesWith(policeCollider) and policeSprite.hittimer == 0 then
        carSprite.speed = carSprite.speed - 280
        policeSprite.speed = 200 + carSprite.speed * 1.1
        camerayShake = camerayShake + 400
        policeSprite.health = math.floor(policeSprite.health - 1)
        if carFrontCollider:collidesWith(policeCollider) then
            policeSprite.y = carSprite.y - 150
        else
            -- policeSprite.y = policeSprite.y
        end

        policeSprite.velocityy = carSprite.speed * 1.5
        policeSprite.hittimer = 0.2
        policeSprite.hittimer1 = 0


        -- if (carSprite.x - policeSprite.x) < 0 then -- Right
        --     policeSprite.velocityx = policeSprite.velocityx + 100 * (carSprite.speed / 1000)
        -- else -- Left
        --     policeSprite.velocityx = policeSprite.velocityx - 100 * (carSprite.speed / 1000)
        -- end

        local velx, vely = splitSpeed(carSprite.speed, carSprite.rotation)
        for i = 1, math.floor(math.random(3,5)) do
            addDebris2(carSprite.x + math.random(-50, 50), carSprite.y + math.random(-50, 50), carSprite.rotation + math.random(-0.2, 0.2), velx, vely)
        end
        if playerDifferencex > 0 then
            policeSprite.velocityx = 75 + carSprite.speed * 0.2
            policeSprite.x = policeSprite.x + 20 + carSprite.speed * 0.005
            policeSprite.rotation = (-math.pi/2) + (math.pi/3) * math.abs(rateOfChangex / 10)
        elseif playerDifferencex <= 0 then
            policeSprite.velocityx = -75 - carSprite.speed * 0.2
            policeSprite.x = policeSprite.x - 20 - carSprite.speed * 0.005
            policeSprite.rotation = (-math.pi/2) - (math.pi/3) * math.abs(rateOfChangex / 10)
        end
    end

    policeSprite.velocityy = policeSprite.velocityy * 0.98
    policeSprite.velocityx = policeSprite.velocityx * 0.98
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

    rightRoadColliderOffset = 1600
    leftRoadColliderOffset = 1600

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
        carSprite.gripRotation = carSprite.rotation
        carSprite.speed = carSprite.speed - 250
        camerayShake = camerayShake + 200
    elseif carCollider:collidesWith(leftRoadCollider) then
        carSprite.x = (road.x + road.image:getWidth() * road.scaleX / 2) - leftRoadColliderOffset + (carSprite.image:getWidth() / 3)
        carSprite.rotation = -math.rad(90 - 15)
        carSprite.gripRotation = carSprite.rotation
        carSprite.speed = carSprite.speed - 250
        camerayShake = camerayShake + 200
    end

    if policeCollider:collidesWith(rightRoadCollider) and policeSprite.crashed == 0 then
        policeSprite.x = (road.x + road.image:getWidth() * road.scaleX / 2) + rightRoadColliderOffset - (carSprite.image:getWidth() / 3)
        policeSprite.rotation = -math.rad(90 + 15)
        policeSprite.speed = policeSprite.speed - 50
    elseif policeCollider:collidesWith(leftRoadCollider) and policeSprite.crashed == 0 then
        policeSprite.x = (road.x + road.image:getWidth() * road.scaleX / 2) - leftRoadColliderOffset + (carSprite.image:getWidth() / 3)
        policeSprite.rotation = -math.rad(90 - 15)
        policeSprite.speed = policeSprite.speed - 50
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

function love.keypressed(key) -- Making debugging so much easier
    if debugMode then
        if key == '1' then
            love.event.quit()
        elseif key == '3' then -- For scaling debugging
            love.window.setMode(192*4, 72*4)
            CScreen.update(192*4, 72*4)
        elseif key == '4' then
            love.window.setMode(1280, 720)
            CScreen.update(1280, 720)
        elseif key == '5' then
            love.window.setMode(1280, 720*2)
            CScreen.update(1280, 720*2)
        elseif key == '6' then
            love.window.setMode(128, 72)
            CScreen.update(128, 72)
        end
    end
    camerayOffset = (1080 / 2) - (love.graphics.getHeight() / 2) + 360
    cameraxScaleOffset = (1920 / 2) - (love.graphics.getWidth() / 2)
end

-- No good sound libraries. Guess I need to make my own sound manager .-.

SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager:new()
    local self = setmetatable({}, SoundManager)
    self.sounds = {}
    self.soundID = 0
    self.songQueue = {}
    self.currentSong = nil
    return self
end

-- function SoundManager:clearSounds() (This didnt work..)
--     self.sounds = {}
--     self.songQueue = {}
--     if self.currentSong then
--         self.currentSong:stop()
--     end
-- end

function SoundManager:addSongToQueue(path, volume, name)
    local song = love.audio.newSource(path, "stream")
    song:setVolume(volume)
    song:setLooping(false)

    if not name then
        self.soundID = self.soundID + 1
        name = "song" .. self.soundID
    end

    self.sounds[name] = song
    table.insert(self.songQueue, name)
end

function SoundManager:playNextSong()
    if self.currentSong then
        self.sounds[self.currentSong]:stop()
        table.insert(self.songQueue, self.currentSong)
    end

    -- Get the next song from the queue
    self.currentSong = table.remove(self.songQueue, 1)

    if self.currentSong then
        self.sounds[self.currentSong]:play()
    end
end

function SoundManager:update(dt)
    if self.currentSong and not self.sounds[self.currentSong]:isPlaying() then
        self:playNextSong()
    end
    for name, sound in pairs(self.sounds) do
        sound:setPitch(1 + (1 - actualGameSpeed) * -0.2)
        sound:setVolume((1 + (1 - actualGameSpeed) * -0.4) * 0.3)

        if exitGame == 1 then
            sound:setPitch(actualGameSpeed)
        end
    end
end

function SoundManager:addSound(name, path, volume, loop)
    local sound = love.audio.newSource(path, "static")
    sound:setVolume(volume)
    sound:setLooping(loop)
    self.sounds[name] = sound
end

function SoundManager:playSound(name)
    if self.sounds[name] then
        self.sounds[name]:setVolume(0.3)
        self.sounds[name]:play()
    end
end

function SoundManager:stopSound(name)
    if self.sounds[name] then
        self.sounds[name]:stop()
    end
end

function love.resize(width, height)
	CScreen.update(width, height)
end

return arcadeGame