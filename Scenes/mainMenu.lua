-- The main menu for the game
mainMenu = {}

-- Car List
carList = {
    {
        carID = 1,
        defaultCarName = "Jerry",
        defaultCarImage = "Sprites/Cars/yellowcar.png",
        maxSpeed = 3500,
        acceleration = 360,
        grip = 30,
        health = 30,
    },
    {
        carID = 2,
        defaultCarName = "Berry",
        defaultCarImage = "Sprites/Cars/Berry.png",
        maxSpeed = 4000,
        acceleration = 700,
        grip = 50,
        health = 10,
    },
    {
        carID = 3,
        defaultCarName = "Police Car",
        defaultCarImage = "Sprites/Cars/PoliceCar.png",
        maxSpeed = 3500,
        acceleration = 400,
        grip = 100,
        health = 30,
    }
}
local carIndex = 1

-- Max speeds (for bar GUIs)
local overallMaxSpeed = 5000
local overallMaxAcceleration = 800
local overallMaxGrip = 100
local overallMaxHealth = 40

-- GUI lists
accelLevelImages = {
    love.graphics.newImage("Sprites/GUI/Acceleration Level/1.png"),
    love.graphics.newImage("Sprites/GUI/Acceleration Level/2.png"),
    love.graphics.newImage("Sprites/GUI/Acceleration Level/3.png"),
    love.graphics.newImage("Sprites/GUI/Acceleration Level/4.png"),
    love.graphics.newImage("Sprites/GUI/Acceleration Level/5.png"),
    love.graphics.newImage("Sprites/GUI/Acceleration Level/6.png"),
}
gripLevelImages = {
    love.graphics.newImage("Sprites/GUI/Grip Level/1.png"),
    love.graphics.newImage("Sprites/GUI/Grip Level/2.png"),
    love.graphics.newImage("Sprites/GUI/Grip Level/3.png"),
    love.graphics.newImage("Sprites/GUI/Grip Level/4.png"),
    love.graphics.newImage("Sprites/GUI/Grip Level/5.png"),
    love.graphics.newImage("Sprites/GUI/Grip Level/6.png"),
}
healthLevelImages = {
    love.graphics.newImage("Sprites/GUI/Health Level/1.png"),
    love.graphics.newImage("Sprites/GUI/Health Level/2.png"),
    love.graphics.newImage("Sprites/GUI/Health Level/3.png"),
    love.graphics.newImage("Sprites/GUI/Health Level/4.png"),
    love.graphics.newImage("Sprites/GUI/Health Level/5.png"),
    love.graphics.newImage("Sprites/GUI/Health Level/6.png"),
}
speedLevelImages = {
    love.graphics.newImage("Sprites/GUI/Speed Level/1.png"),
    love.graphics.newImage("Sprites/GUI/Speed Level/2.png"),
    love.graphics.newImage("Sprites/GUI/Speed Level/3.png"),
    love.graphics.newImage("Sprites/GUI/Speed Level/4.png"),
    love.graphics.newImage("Sprites/GUI/Speed Level/5.png"),
    love.graphics.newImage("Sprites/GUI/Speed Level/6.png"),
}
local guiPositionx = 900
local guiPositiony = 600

-- SUIT setup (This is gonna make the GUI so much easier to make..)
local suit = require("SUIT")

-- library setup
local CScreen = require "cscreen"

-- odd bug fix
firstMenuLoad = 1

-- misc. setup
local screenWidthA = love.graphics.getWidth()
local screenHeightA = love.graphics.getHeight()
local screenWidth = 1920
local screenHeight = 1080
local mac = {}

local darkOffset = 0
local darkCurrent = 0

local selectLeftImage = love.graphics.newImage("Sprites/GUI/leftCarSelect.png")
local selectRightImage = love.graphics.newImage("Sprites/GUI/rightCarSelect.png")
local optionsIcon = love.graphics.newImage("Sprites/GUI/gearIcon.png")

-- Precalculate button positions in options menu
local numberOfButtons = 4
local buttonHeight = 250

local usableHeight = screenHeight - (2 * 50)
local totalButtonHeight = numberOfButtons * buttonHeight
local gapSpace = usableHeight - totalButtonHeight
local gapHeight = gapSpace / (numberOfButtons - 1)

-- Precalculate button positions in main menu
local numberOfButtons1 = 3
local buttonWidth = 500

local usableWidth = screenWidth - (2 * 50)
local totalButtonWidth = numberOfButtons1 * buttonWidth
local gapSpace1 = usableWidth - totalButtonWidth
local gapWidth = gapSpace1 / (numberOfButtons1 - 1)

-- anim setup
local currentAnimation = 0
local animatedDebris = {}

local screen = "mainMenu"

gameData = {
    distanceTraveledHIGHSCORE = 0,
    nearMissesHIGHSCORE = 0,
    awesomeNearMissesHIGHSCORE = 0,
    policeTakedownsHIGHSCORE = 0,
    EMPDodgesHIGHSCORE = 0,
    timeSurvivedHIGHSCORE = 0,
    playerGarage = {
        {
            carID = 1,
            carName = "Jerry",
        },
        {
            carID = 2,
            carName = "Berry",
            -- carImage = "path/to/image3.png",
        }
    }
}

function mainMenu.load()

    -- Scaling init
    CScreen.init(math.max(love.graphics.getWidth(), 1920), 1080, debugMode)

    love.window.setTitle("Horizon Driving - Main Menu")
    screenWidthA = love.graphics.getWidth()
    screenHeightA = love.graphics.getHeight()

    if firstStart == true then
        -- saveGame()
        loadGame()
        firstStart = false
    else
        saveGame()
    end

    loadAnimations()

    -- Load sound(s)
    bgSong = love.audio.newSource("Sounds/NaturalHighSnip.mp3", "stream")
    bgSong:setLooping(true)
    bgSong:setVolume(0.2)

    -- Play bg song
    bgSong:play()

    -- Set SUIT colors
    suit.theme.color.normal.fg = {255,255,255}
    suit.theme.color.hovered = {bg = {200,230,255}, fg = {0,0,0}}
    suit.theme.color.active = {bg = {150,150,150}, fg = {0,0,0}}

    -- Load font
    font = love.graphics.newFont("fonts/VCR_OSD_MONO.ttf", 100 * math.min(scaleStuff("w"), scaleStuff("h"))) -- The font
    font1 = love.graphics.newFont("fonts/VCR_OSD_MONO.ttf", 75 * math.min(scaleStuff("w"), scaleStuff("h")))
    font2 = love.graphics.newFont("fonts/VCR_OSD_MONO.ttf", 50 * math.min(scaleStuff("w"), scaleStuff("h")))
    font3 = love.graphics.newFont("fonts/VCR_OSD_MONO.ttf", 25 * math.min(scaleStuff("w"), scaleStuff("h")))
    love.graphics.setFont(font)

    screen = "mainMenu"

    -- print(love.filesystem.read("saveFile.txt"))
    carIndex = 1
    playerCarInfo = getCarInfo(carIndex)
    print("Car info at index: " .. carIndex)
    if playerCarInfo then
        print("Name:", playerCarInfo.name)
        print("Image:", playerCarInfo.image)
        print("Max Speed:", playerCarInfo.maxSpeed)
        print("Acceleration:", playerCarInfo.acceleration)
        print("Grip:", playerCarInfo.grip)
        print("Health:", playerCarInfo.health)
    else
        print("Car not found.")
    end
end

function getCarInfo(index)
    local playerCar = gameData.playerGarage[index]
    if not playerCar then
        print("getCarInfo() GARAGE INDEX FAILURE (Player Car not present at: " .. index .. ")")
        return nil -- No car found
    end

    local carInfo
    for _, car in ipairs(carList) do
        if car.carID == playerCar.carID then
            carInfo = car
            break
        end
    end

    if not carInfo then
        print("getCarInfo() DATA INDEX FAILURE (Car Data not present at: " .. index .. ")")
        return nil -- CarID not found
    end

    local carData = {
        name = playerCar.carName or carInfo.defaultCarName,
        image = playerCar.carImage or carInfo.defaultCarImage,
        maxSpeed = carInfo.maxSpeed,
        acceleration = carInfo.acceleration,
        grip = carInfo.grip,
        health = carInfo.health
    }

    return carData
end

function mainMenu.update(dt)
    if love.keyboard.isDown('p') then -- DEBUG
        bgSong:stop()
        return "mainMenu"
    end

    darkOffset = 0
    local darkDifference = darkOffset - darkCurrent
    darkCurrent = darkCurrent + darkDifference * 0.2
    suit.layout:reset(0, 0)

    love.graphics.setFont(font)

    if screen == "carSelect" then
        if suit.Button("Play", (screenWidth - 350) * scaleStuff("w"), (screenHeight - 275) * scaleStuff("h"),
            300 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
                firstMenuLoad = 0
                bgSong:stop()
                return "startGame"
        end

        if suit.Button("Back", (screenWidth - 350) * scaleStuff("w"),  (screenHeight - 275 - 150) * scaleStuff("h"), 300 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
            mac.counter = 0
            mac.switchAnimation = 1
            loadAnimations()
            screen = "mainMenu"
        end

        suit.Label("CAR SELECT", {align = "left"},
        (25 * scaleStuff("w")), (-15 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))

        suit.Label(playerCarInfo.name, {align = "left"},
        (screenWidth - 50 - (#playerCarInfo.name * 60) * scaleStuff("w")), (-15 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))

        love.graphics.setFont(font1)

        -- suit.Label("Speed: " .. (playerCarInfo.maxSpeed/10), {align = "left"},
        -- (screenWidth - 50 - (7*45) - (#tostring(playerCarInfo.maxSpeed/10) * 45) * scaleStuff("w")), (50 * scaleStuff("h")),
        -- (11*45) + (#tostring(playerCarInfo.maxSpeed/10) * 45) * scaleStuff("w"), 150 * scaleStuff("h"))

        -- suit.Label("Accel: " .. (playerCarInfo.acceleration/10), {align = "left"},
        -- (screenWidth - 50 - (7*45) - (#tostring(playerCarInfo.acceleration/10) * 45) * scaleStuff("w")), (100 * scaleStuff("h")),
        -- (11*45) + (#tostring(playerCarInfo.acceleration/10) * 45) * scaleStuff("w"), 150 * scaleStuff("h"))

        -- suit.Label("Grip: " .. (playerCarInfo.grip), {align = "left"},
        -- (screenWidth - 50 - (6*45) - (#tostring(playerCarInfo.grip) * 45) * scaleStuff("w")), (150 * scaleStuff("h")),
        -- (11*45) + (#tostring(playerCarInfo.grip) * 45) * scaleStuff("w"), 150 * scaleStuff("h"))

        -- suit.Label("Health: " .. (playerCarInfo.health), {align = "left"},
        -- (screenWidth - 50 - (8*45) - (#tostring(playerCarInfo.health) * 45) * scaleStuff("w")), (200 * scaleStuff("h")),
        -- (11*45) + (#tostring(playerCarInfo.health) * 45) * scaleStuff("w"), 150 * scaleStuff("h"))

        -- love.graphics.setFont(font2)
        -- suit.Label("CLICK TO CHANGE", {align = "left"},
        -- (1000 * scaleStuff("w")), (500 * scaleStuff("h")), 800 * scaleStuff("w"), 25 * scaleStuff("h"))

        local guiSpeed = 0.5

        guiPositionx = guiPositionx + (mac.playerx - guiPositionx) * guiSpeed * dt
        guiPositiony = guiPositiony + (mac.playery - guiPositiony) * guiSpeed * dt

        -- local levelguiyOffset = 100

        -- print(guiPositiony)
        
        -- print(calculateLevelFractions(playerCarInfo.grip, overallMaxGrip, 6))

        if suit.ImageButton(selectLeftImage, ((guiPositionx - 250) * scaleStuff("w")), ((guiPositiony - 50) * scaleStuff("h")), 2 * scaleStuff("w"), 2 * scaleStuff("h")).hit then
            -- Select to left (if there is a car to the left)
            if carIndex ~= 1 then
                carIndex = carIndex - 1
            end

            -- print(love.filesystem.read("saveFile.txt"))
            playerCarInfo = getCarInfo(carIndex)
            print("Car info at index: " .. carIndex)
            if playerCarInfo then
                print("Name:", playerCarInfo.name)
                print("Image:", playerCarInfo.image)
                print("Max Speed:", playerCarInfo.maxSpeed)
                print("Acceleration:", playerCarInfo.acceleration)
                print("Grip:", playerCarInfo.grip)
                print("Health:", playerCarInfo.health)
            else
                print("Car not found.")
            end
        elseif suit.ImageButton(selectRightImage, ((guiPositionx + 100) * scaleStuff("w")), ((guiPositiony - 50) * scaleStuff("h")), 2 * scaleStuff("w"), 2 * scaleStuff("h")).hit then
            -- Select to right (if there is a car to the right)
            if carIndex ~= #gameData.playerGarage then
                carIndex = carIndex + 1
            end
            
            -- print(love.filesystem.read("saveFile.txt"))
            playerCarInfo = getCarInfo(carIndex)
            print("Car info at index: " .. carIndex)
            if playerCarInfo then
                print("Name:", playerCarInfo.name)
                print("Image:", playerCarInfo.image)
                print("Max Speed:", playerCarInfo.maxSpeed)
                print("Acceleration:", playerCarInfo.acceleration)
                print("Grip:", playerCarInfo.grip)
                print("Health:", playerCarInfo.health)
            else
                print("Car not found.")
            end
        end
        mac.playerImage = love.graphics.newImage(playerCarInfo.image)

        carSelectUpdate(dt)

    elseif screen == "playerGarage" then
        darkOffset = 0.5
        local darkDifference = darkOffset - darkCurrent
        darkCurrent = darkCurrent + darkDifference * 0.2

        if suit.Button("Back", (screenWidth - 325) * scaleStuff("w"), 20 * scaleStuff("h"),
        300 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
            screen = "mainMenu"
        end

        love.graphics.setFont(font2)

        suit.Label("Car Garage is a work in progress!", {align = "left"},
        (25 * scaleStuff("w")), (25 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
    elseif screen == "carShop" then
        darkOffset = 0.5
        local darkDifference = darkOffset - darkCurrent
        darkCurrent = darkCurrent + darkDifference * 0.2

        if suit.Button("Back", (screenWidth - 325) * scaleStuff("w"), 20 * scaleStuff("h"),
        300 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
            screen = "mainMenu"
        end

        love.graphics.setFont(font2)

        suit.Label("Car Shop is a work in progress!", {align = "left"},
        (25 * scaleStuff("w")), (25 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
    else
        updateAnimations(dt)
        
        -- Prepare GUI
        if screen == "mainMenu" then

            if suit.Button("Shop", (50) * scaleStuff("w"), (screenHeight - 225) * scaleStuff("h"),
            buttonWidth * scaleStuff("w"), 150 * scaleStuff("h")).hit then
                screen = "carShop"
            end

            if suit.Button("Garage", (50 + buttonWidth + gapWidth) * scaleStuff("w"), (screenHeight - 225) * scaleStuff("h"),
            buttonWidth * scaleStuff("w"), 150 * scaleStuff("h")).hit then
                screen = "playerGarage"
            end

            if suit.Button("Play", (50 + 2 * buttonWidth + 2 * gapWidth) * scaleStuff("w"), (screenHeight - 225) * scaleStuff("h"),
            buttonWidth * scaleStuff("w"), 150 * scaleStuff("h")).hit then
                carSelectLoad()
                screen = "carSelect"
            end
            
            if suit.ImageButton(optionsIcon, (screenWidth * scaleStuff("w")) - 150, 20 * scaleStuff("h"), 1, 1).hit then
                screen =  "options"
            end

            love.graphics.setFont(font2)
            
            suit.Label("Made by: Logan Peterson (With LOVE)", {align = "center"},
            ((screenWidth - 1050)) * scaleStuff("w"), (screenHeight - 75) * scaleStuff("h"),
            1050 * scaleStuff("w"), 75 * scaleStuff("h"))
            
        elseif screen == "options" then
            darkOffset = 0.5
            local darkDifference = darkOffset - darkCurrent
            darkCurrent = darkCurrent + darkDifference * 0.2

            if suit.Button("Back", (screenWidth - 325) * scaleStuff("w"), 20 * scaleStuff("h"),
            300 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
                screen = "mainMenu"
            end

            if suit.Button("Help", (screenWidth/2 - 325) * scaleStuff("w"), (50) * scaleStuff("h"),
            650 * scaleStuff("w"), buttonHeight * scaleStuff("h")).hit then
                screen = "help"
            end
            
            if suit.Button("Highscores", (screenWidth/2 - 325) * scaleStuff("w"), (50 + buttonHeight + gapHeight) * scaleStuff("h"),
            650 * scaleStuff("w"), buttonHeight * scaleStuff("h")).hit then
                screen = "highscores"
            end

            if suit.Button("Settings", (screenWidth/2 - 325) * scaleStuff("w"), (50 + 2 * buttonHeight + 2 * gapHeight) * scaleStuff("h"),
            650 * scaleStuff("w"), buttonHeight * scaleStuff("h")).hit then
                screen = "settings"
            end
            
            if suit.Button("Quit", (screenWidth/2 - 325) * scaleStuff("w"), (50 + 3 * buttonHeight + 3 * gapHeight) * scaleStuff("h"),
            650 * scaleStuff("w"), buttonHeight * scaleStuff("h")).hit then
                love.event.quit()
            end
        elseif screen == "settings" then
            darkOffset = 0.5
            local darkDifference = darkOffset - darkCurrent
            darkCurrent = darkCurrent + darkDifference * 0.2

            if suit.Button("Back", (screenWidth - 325) * scaleStuff("w"), 20 * scaleStuff("h"),
            300 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
                screen = "options"
            end
    
            love.graphics.setFont(font2)
    
            suit.Label("No Settings to tweak yet!", {align = "left"},
            (25 * scaleStuff("w")), (25 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))

        elseif screen == "highscores" then
            darkOffset = 0.5
            local darkDifference = darkOffset - darkCurrent
            darkCurrent = darkCurrent + darkDifference * 0.2
    
            if suit.Button("Back", (screenWidth - 325) * scaleStuff("w"), 20 * scaleStuff("h"),
            300 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
                screen = "options"
            end
    
            love.graphics.setFont(font1)
    
            suit.Label("Highscores:", {align = "left"},
            (25 * scaleStuff("w")), (25 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
            love.graphics.setFont(font2)
            local decimalPlaces = 2
            suit.Label("Distance Traveled: " .. roundNumber(gameData.distanceTraveledHIGHSCORE * 0.1 / 60, decimalPlaces), {align = "left"},
            (25 * scaleStuff("w")), (125 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
            suit.Label("Near Misses: " .. roundNumber(gameData.nearMissesHIGHSCORE, decimalPlaces), {align = "left"},
            (25 * scaleStuff("w")), (225 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
            suit.Label("Awesome Near Misses: " .. roundNumber(gameData.awesomeNearMissesHIGHSCORE, decimalPlaces), {align = "left"},
            (25 * scaleStuff("w")), (325 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
            suit.Label("Police Takedowns: " .. roundNumber(gameData.policeTakedownsHIGHSCORE, decimalPlaces), {align = "left"},
            (25 * scaleStuff("w")), (425 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
            suit.Label("EMP Dodges: " .. roundNumber(gameData.EMPDodgesHIGHSCORE, decimalPlaces), {align = "left"},
            (25 * scaleStuff("w")), (525 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
            suit.Label("Time Survived: " .. roundNumber(gameData.timeSurvivedHIGHSCORE, decimalPlaces), {align = "left"},
            (25 * scaleStuff("w")), (625 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
        elseif screen == "help" then
            darkOffset = 0.5
            local darkDifference = darkOffset - darkCurrent
            darkCurrent = darkCurrent + darkDifference * 0.2
    
            if suit.Button("Back", (screenWidth - 325) * scaleStuff("w"), 20 * scaleStuff("h"),
            300 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
                screen = "options"
            end
    
            love.graphics.setFont(font2)
    
            suit.Label("No help screen yet lol", {align = "left"},
            (25 * scaleStuff("w")), (25 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
        end
    end

    return nil
end

function calculateLevelFractions(amount, maxAmount, indexLength)
    local fraction = amount / maxAmount
    return math.floor((fraction * indexLength) + 0.5)
end

function roundNumber(number, decimalPlaces) -- Currently just cuts it off at that specified decimal
    return math.floor(number * (math.pow(10, decimalPlaces))) / (math.pow(10, decimalPlaces))
end

function mainMenu.draw()
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
    if mac.policeAppear == 1 then
        love.graphics.draw(mac.policeImage, math.floor(mac.policex),
        math.floor(mac.policey), mac.policeRotation,
        mac.policeScaleX, mac.policeScaleY,
        mac.policeRotationX, mac.policeRotationY)
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
    -- Draw GUI
    suit.draw()
    
    if screen == "carSelect" then
        love.graphics.push()
        
        love.graphics.translate(guiPositionx * scaleStuff("h"), guiPositiony * scaleStuff("w"))
        love.graphics.rotate(math.rad(90))
        love.graphics.print(" Speed:", -250, 360 * scaleStuff("w"))
        love.graphics.print(" Accel:", -250, 260 * scaleStuff("w"))
        love.graphics.print("  Grip:", -250, -340 * scaleStuff("w"))
        love.graphics.print("Health:", -250, -440 * scaleStuff("w"))
    
        love.graphics.pop()

        local levelguiyOffset = -100
        local statScale = 1 * scaleStuff("w")
        local statImageSizeExample = speedLevelImages[1]
        local statImageRX = statImageSizeExample:getWidth() / 2
        local statImageRY = statImageSizeExample:getHeight() / 2

        love.graphics.draw(speedLevelImages[calculateLevelFractions(playerCarInfo.maxSpeed, overallMaxSpeed, 6)],
        ((guiPositionx - 400) * scaleStuff("w")), ((guiPositiony) * scaleStuff("h")) - levelguiyOffset,
        0, statScale, statScale,
        statImageRX, statImageRY)
        
        love.graphics.draw(accelLevelImages[calculateLevelFractions(playerCarInfo.acceleration, overallMaxAcceleration, 6)],
        ((guiPositionx - 300) * scaleStuff("w")), ((guiPositiony) * scaleStuff("h")) - levelguiyOffset,
        0, statScale, statScale,
        statImageRX, statImageRY)
        love.graphics.draw(gripLevelImages[calculateLevelFractions(playerCarInfo.grip, overallMaxGrip, 6)],
        ((guiPositionx + 300) * scaleStuff("w")), ((guiPositiony) * scaleStuff("h")) - levelguiyOffset,
        0, statScale, statScale,
        statImageRX, statImageRY)
        love.graphics.draw(healthLevelImages[calculateLevelFractions(playerCarInfo.health, overallMaxHealth, 6)],
        ((guiPositionx + 400) * scaleStuff("w")), ((guiPositiony) * scaleStuff("h")) - levelguiyOffset,
        0, statScale, statScale,
        statImageRX, statImageRY)
    end
end

function carSelectLoad()
    mac.switchAnimation = 0
    mac.stage = 0
    mac.counter = 0
    
    animScale = 0.475

    mac.playerAppear = 1
    mac.playerImage = love.graphics.newImage(playerCarInfo.image)
    mac.playerx = 650
    mac.playery = 400
    mac.playerRotation = 0
    mac.playerScaleX = animScale
    mac.playerScaleY = animScale
    mac.playerRotation = math.rad(145 - 90)
    
    mac.policeAppear = 1
    mac.policex = 750
    mac.policey = 200
    mac.policeRotation = 0
    mac.policeScaleX = animScale
    mac.policeScaleY = animScale
    mac.policeRotation = math.rad(145 - 90)
    mac.road1x = 1800
    mac.road1y = 200
    mac.roadScaleX = animScale * 8
    mac.roadScaleY = animScale * 8
    mac.roadRotation = math.rad(145)

    clearDebris()
end

function carSelectUpdate(dt)
    mac.timer = mac.timer + dt


    mac.road1x = mac.road1x - 4500 * math.sin(mac.roadRotation) * dt
    mac.road1y = mac.road1y - 4500 * -math.cos(mac.roadRotation) * dt

    mac.policex = 950 + math.sin(mac.timer/1.5) * 15
    mac.policey = 300 + math.cos(mac.timer/2) * 15

    mac.playerx = 900 + math.sin(mac.timer/1.2) * 15
    mac.playery = 600 + math.cos(mac.timer/1.7) * 15

    if mac.road2x <= 1800 then
        mac.road1x = 1800
        mac.road1y = 200
    end

    updateRoad()
end

function loadAnimations(dt)
    currentAnimation = 0 -- SET TO 0 WHEN ANIMATIONS DONE!!!

    menuAnimationImages = {
        playerCar = love.graphics.newImage("Sprites/Cars/Berry.png"),
        policeCar = love.graphics.newImage("Sprites/Cars/PoliceCar.png"),
        trafficCar = love.graphics.newImage("Sprites/Cars/yellowcar.png"),
        road = love.graphics.newImage("Sprites/road1.png"),
    }

    mac = { -- Menu animation container
        playerx = 0, -- Player Car
        playery = 0,
        playerRotation = 0,
        playerRotationX = menuAnimationImages.playerCar:getWidth() / 2,
        playerRotationY = menuAnimationImages.playerCar:getHeight() / 2,
        playerScaleX = 1,
        playerScaleY = 1,
        playerAppear = 0,
        playerImage = menuAnimationImages.playerCar,

        policex = 0, -- Police Car
        policey = 0,
        policeRotation = 0,
        policeRotationX = menuAnimationImages.policeCar:getWidth() / 2,
        policeRotationY = menuAnimationImages.policeCar:getHeight() / 2,
        policeScaleX = 1,
        policeScaleY = 1,
        policeAppear = 0,
        policeImage = menuAnimationImages.policeCar,

        trafficx = 0, -- Traffic Car
        trafficy = 0,
        trafficRotation = 0,
        trafficRotationX = menuAnimationImages.trafficCar:getWidth() / 2,
        trafficRotationY = menuAnimationImages.trafficCar:getHeight() / 2,
        trafficScaleX = 1,
        trafficScaleY = 1,
        trafficAppear = 0,
        trafficImage = menuAnimationImages.trafficCar,

        road1x = 0,
        road2x = 0,
        road1y = 0,
        road2y = 0,
        roadRotation = 0,
        roadRotationX = menuAnimationImages.road:getWidth() / 2,
        roadRotationY = menuAnimationImages.road:getHeight() / 2,
        roadScaleX = 1,
        roadScaleY = 1,
        roadAppear = 0,
        roadImage = menuAnimationImages.road,

        switchAnimation = 1,
        timer = 0,
        stage = 0,
        counter = 0
    }
end

function updateAnimations(dt)
    mac.timer = mac.timer - 1

    if mac.timer < 0 then
        mac.timer = 0
    end

    if currentAnimation == 0 then
        if mac.switchAnimation == 1 then
            mac.switchAnimation = 0
            mac.stage = 0
            mac.counter = 0
            
            animScale = 0.65

            mac.playerAppear = 1
            mac.playerImage = love.graphics.newImage("Sprites/Cars/Berry.png")
            mac.playerx = 100
            mac.playery = 500
            mac.playerRotation = 0
            mac.playerScaleX = animScale
            mac.playerScaleY = animScale
            
            mac.policeAppear = 1
            mac.policex = 1200
            mac.policey = 400
            mac.policeRotation = 0
            mac.policeScaleX = animScale
            mac.policeScaleY = animScale

            mac.trafficAppear = 0

            mac.road1x = 200
            mac.road1y = -450
            mac.roadScaleX = animScale * 8
            mac.roadScaleY = animScale * 8
            mac.roadRotation = math.rad(90)

            mac.timer = 140

            clearDebris()
        end
        
        if mac.stage == 3 and mac.timer == 0 then
        else
            mac.playery = mac.playery + (58 * math.sin(mac.playerRotation))
            mac.policex = mac.policex + 0.4
            mac.road1x = mac.road1x - 58
            if mac.stage > 0 and mac.stage < 2 then
                mac.playerx = mac.playerx + 5
            else
                mac.playerx = mac.playerx + 4.1
            end
        end
        
        if mac.stage == 0 and mac.timer == 0 then
            if mac.counter <= 20 then
                mac.playerRotation = mac.playerRotation + math.rad(.5)
                mac.counter = mac.counter + 1
            else
                mac.stage = mac.stage + 1
                mac.counter = 0
            end
        elseif mac.stage == 1 then
            if mac.counter <= 20 then
                mac.playerRotation = mac.playerRotation - math.rad(.5)
                mac.counter = mac.counter + 1
            else
                mac.stage = mac.stage + 1
                mac.counter = 0
                mac.timer = 30
            end
        elseif mac.stage == 2 and mac.timer == 0 then
            if mac.counter <= 20 then
                mac.playerRotation = mac.playerRotation - math.rad(0.8)
                mac.counter = mac.counter + 1
            else
                mac.stage = mac.stage + 1
                mac.counter = 0
                mac.timer = 0
            end
        elseif mac.stage == 3 and mac.timer == 0 then
            if mac.counter <= 30 then
                -- local carHeight = mac.playerImage:getHeight() - 50
                -- local carEndX = mac.playerx + carHeight * math.cos(mac.playerRotation)
                -- local carEndY = mac.playery + carHeight * math.sin(mac.playerRotation)
                
                mac.policex = mac.policex + 1
                mac.policey = mac.policey - 3
                mac.policeRotation = mac.policeRotation + math.rad(1)

                mac.playerx = mac.playerx + 2
                mac.playery = mac.playery - 3
                mac.playerRotation = mac.playerRotation - math.rad(0.5)

                mac.road1x = mac.road1x - 3

                mac.counter = mac.counter + 1
            else
                mac.stage = mac.stage + 1
                mac.counter = 0
            end
        elseif mac.stage == 4 and mac.timer == 0 then
            currentAnimation = 1
            mac.switchAnimation = 1
        end

        -- print("R1x: " .. tostring(mac.road1x) .. "R2x: " .. tostring(mac.road2x))
        if mac.road2x <= 200 then
            mac.road1x = 200
        end

    elseif currentAnimation == 1 then
        if mac.switchAnimation == 1 then
            mac.switchAnimation = 0
            mac.stage = 0
            mac.counter = 0
            
            animScale = 1

            mac.playerAppear = 1
            mac.playerImage = love.graphics.newImage("Sprites/Cars/Berry.png")
            mac.playerx = 1100
            mac.playery = 625
            mac.playerRotation = 0
            mac.playerScaleX = animScale
            mac.playerScaleY = animScale
            mac.playerRotation = math.rad(-80)
            
            mac.policeAppear = 1
            mac.policex = 1200
            mac.policey = 300
            mac.policeRotation = 0
            mac.policeScaleX = animScale
            mac.policeScaleY = animScale
            mac.policeRotation = math.rad(5)
            mac.road1x = 200
            mac.road1y = -450
            mac.roadScaleX = animScale * 8
            mac.roadScaleY = animScale * 8
            mac.roadRotation = math.rad(40)

            clearDebris()
        end

        if mac.stage == 0 then
            if mac.counter <= 150 then      
                mac.policex = mac.policex + 0.25
                mac.policey = mac.policey - 0.75
                mac.policeRotation = mac.policeRotation + math.rad(0.2)

                mac.playerx = mac.playerx + 0.5
                mac.playery = mac.playery - 0.75
                mac.playerRotation = mac.playerRotation - math.rad(0.1)

                mac.road1x = mac.road1x - 1
                mac.road1y = mac.road1y + 1

                mac.counter = mac.counter + 1
            else
                mac.stage = mac.stage + 1
                mac.counter = 0
            end
        elseif mac.stage == 1 then
            currentAnimation = 2
            mac.switchAnimation = 1
        end

    elseif currentAnimation == 2 then
        if mac.switchAnimation == 1 then
            mac.switchAnimation = 0
            mac.stage = 0
            mac.counter = 0
            
            animScale = 0.5

            mac.playerAppear = 1
            mac.playerImage = love.graphics.newImage("Sprites/Cars/Berry.png")
            mac.playerx = 650
            mac.playery = -100
            mac.playerRotation = 0
            mac.playerScaleX = animScale
            mac.playerScaleY = animScale
            mac.playerRotation = math.rad(170 - 90)
            
            mac.policeAppear = 1
            mac.policex = 750
            mac.policey = -900
            mac.policeRotation = 0
            mac.policeScaleX = animScale
            mac.policeScaleY = animScale
            mac.policeRotation = math.rad(170 - 90)
            mac.road1x = 1800
            mac.road1y = -200
            mac.roadScaleX = animScale * 8
            mac.roadScaleY = animScale * 8
            mac.roadRotation = math.rad(170)

            clearDebris()
        end

        if mac.stage == 0 then
            if mac.counter <= 160 then
                mac.policex = mac.policex + 825 * math.sin(mac.roadRotation) * dt
                mac.policey = mac.policey + 825 * -math.cos(mac.roadRotation) * dt

                mac.playerx = mac.playerx + 850 * math.sin(mac.roadRotation) * dt
                mac.playery = mac.playery + 850 * -math.cos(mac.roadRotation) * dt

                mac.road1x = mac.road1x - 4500 * math.sin(mac.roadRotation) * dt
                mac.road1y = mac.road1y - 4500 * -math.cos(mac.roadRotation) * dt

                mac.counter = mac.counter + 1
            else
                mac.stage = mac.stage + 1
                mac.counter = 0
            end
        elseif mac.stage == 1 then
            currentAnimation = 3
            mac.switchAnimation = 1
        end

        if mac.road2x <= 1800 then
            mac.road1x = 1800
            mac.road1y = -200
        end

    elseif currentAnimation == 3 then
        if mac.switchAnimation == 1 then
            mac.switchAnimation = 0
            mac.stage = 0
            mac.counter = 0
            
            animScale = 1

            mac.playerAppear = 1
            mac.playerImage = love.graphics.newImage("Sprites/Cars/Berry.png")
            mac.playerx = 1200
            mac.playery = 300
            mac.playerRotation = 0
            mac.playerScaleX = animScale
            mac.playerScaleY = animScale
            mac.playerRotation = math.rad(110)
            
            mac.policeAppear = 0

            mac.trafficAppear = 1
            mac.trafficx = 1100
            mac.trafficy = 700
            mac.trafficRotation = 0
            mac.trafficScaleX = animScale
            mac.trafficScaleY = animScale
            mac.trafficRotation = math.rad(50)
            mac.road1x = 2600
            mac.road1y = 0
            mac.roadScaleX = animScale * 8
            mac.roadScaleY = animScale * 8
            mac.roadRotation = math.rad(200)

            clearDebris()

            addDebris(1200, 550, 0, -.1, -.1, -.005)
            addDebris(1100, 450, 1, .1, -.1, .004)
            addDebris(1100, 400, 2, -.1, -.1, -.003)
        end

        if mac.stage == 0 then
            if mac.counter <= 150 then      
                mac.trafficx = mac.trafficx - 0.25
                mac.trafficy = mac.trafficy + 0.75
                mac.trafficRotation = mac.trafficRotation - math.rad(0.1)

                mac.playerx = mac.playerx - 0.5
                mac.playery = mac.playery + 0.75
                mac.playerRotation = mac.playerRotation - math.rad(0.05)

                mac.road1x = mac.road1x + 1
                mac.road1y = mac.road1y - 1

                mac.counter = mac.counter + 1
            else
                mac.stage = mac.stage + 1
                mac.counter = 0
            end
        elseif mac.stage == 1 then
            currentAnimation = 0
            mac.switchAnimation = 1
        end

    -- elseif currentAnimation == 4 then
    --     if mac.switchAnimation == 1 then
    --         mac.switchAnimation = 0
    --     end

    end

    updateRoad()
    updateDebris1()
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

function updateDebris1() -- I shouldnt need to make a new name? Trying to make them local functions didnt seem to work so whatever..
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

-- Saving system!!
function saveGame()
    local success, message = love.filesystem.write("saveFile.txt", tableToString(gameData))
    if success then
        print("Game saved!")
        printTable(gameData, "  ")
        -- print(love.filesystem.read("saveFile.txt"))
    else
        print("Could not save game. Error: " .. message)
    end
end

function loadGame()
    if love.filesystem.getInfo("saveFile.txt") and love.filesystem.read("saveFile.txt") ~= nil then
        local str = love.filesystem.read("saveFile.txt")
        -- print(str)
        gameData = stringToTable(str)
        -- gameData.distanceTraveledHIGHSCORE = 10000
        if gameData.distanceTraveledHIGHSCORE ~= nil then
            print("Game loaded!")
        else
            print("Error while loading gamesave!")
        end
        printTable(gameData, "  ")
    else
        print("No save file found.")
    end
end

function file_exists(name)
    local file = io.open(name,"r")
    if file ~= nil then 
        io.close(file) 
        print("Save File Exists!")
        return true
    else 
        print("Save File DOES NOT Exist!")
        return false 
    end
end

function tableToString(tbl, indent)
    indent = indent or ''
    local format = string.format

    local function formatKey(key)
        if type(key) == 'string' and key:match('^[_%a][_%w]*$') then
            return key
        else
            return format('[%s]', tostring(key))
        end
    end

    local function formatValue(value)
        if type(value) == 'string' then
            return format('%q', value)
        else
            return tostring(value)
        end
    end

    local lines = {}
    for k, v in pairs(tbl) do
        local key = formatKey(k)
        if type(v) == 'table' then
            table.insert(lines, format('%s%s = {\n%s\n%s},', indent, key, tableToString(v, indent .. '    '), indent))
        else
            table.insert(lines, format('%s%s = %s,', indent, key, formatValue(v)))
        end
    end
    return table.concat(lines, '\n')
end

function stringToTable(str)
    local formattedStr = "return {\n" .. str .. "\n}"
    local func, err = load(formattedStr)
    if func then
        local ok, result = pcall(func)
        if ok then
            return result
        else
            error("Failed to parse string: " .. result)
        end
    else
        error("Failed to load string: " .. err)
    end
end

function printTable(tbl, indent)
    print("Save Data:")
    printTable1(tbl, indent)
end

function printTable1(tbl, indent)
    if not indent then indent = '' end
    
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            print(indent .. k .. " = ")
            printTable1(v, indent .. "  ")
        else
            print(indent .. k .. " = " .. tostring(v))
        end
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

return mainMenu