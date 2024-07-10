-- The main menu for the game
mainMenu = {}

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

local darkOffset = 0
local darkCurrent = 0

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
    timeSurvivedHIGHSCORE = 0
}

function mainMenu.load()
    -- Update game data list
    -- gameData = {
    --     distanceTraveledHIGHSCORE,
    --     nearMissesHIGHSCORE,
    --     awesomeNearMissesHIGHSCORE,
    --     policeTakedownsHIGHSCORE,
    --     EMPDodgesHIGHSCORE,
    --     timeSurvivedHIGHSCORE
    -- }

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
end

function mainMenu.update(dt)
    -- Update game data list
    -- gameData = {
    --     distanceTraveledHIGHSCORE,
    --     nearMissesHIGHSCORE,
    --     awesomeNearMissesHIGHSCORE,
    --     policeTakedownsHIGHSCORE,
    --     EMPDodgesHIGHSCORE,
    --     timeSurvivedHIGHSCORE
    -- }
    -- print("DistanceTH: " .. gameData["distanceTraveledHIGHSCORE"])

    updateAnimations(dt)

    if love.keyboard.isDown('p') then -- DEBUG
        return "mainMenu"
    end

    -- Prepare GUI
    if screen == "mainMenu" then
        darkOffset = 0
        local darkDifference = darkOffset - darkCurrent
        darkCurrent = darkCurrent + darkDifference * 0.2
        suit.layout:reset(0, 0)

        love.graphics.setFont(font)

        if suit.Button("Play", 50 * scaleStuff("w"), (screenHeight - 225) * scaleStuff("h"),
        300 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
            firstMenuLoad = 0
            return "startGame"
        end

        if suit.Button("Help", 400 * scaleStuff("w"), (screenHeight - 225) * scaleStuff("h"),
        300 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
            screen = "help"
        end

        if suit.Button("Highscores", 750 * scaleStuff("w"), (screenHeight - 225) * scaleStuff("h"),
        650 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
            screen = "highscores"
        end

        if suit.Button("Quit", 1450 * scaleStuff("w"), (screenHeight - 225) * scaleStuff("h"),
        300 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
            love.event.quit()
        end

        love.graphics.setFont(font2)

        suit.Label("Made by: Logan Peterson (With LOVE)", {align = "center"},
        ((screenWidth - 1050)) * scaleStuff("w"), (screenHeight - 75) * scaleStuff("h"),
        1050 * scaleStuff("w"), 75 * scaleStuff("h"))

    elseif screen == "highscores" then
        darkOffset = 0.5
        local darkDifference = darkOffset - darkCurrent
        darkCurrent = darkCurrent + darkDifference * 0.2

        if suit.Button("Back", (screenWidth - 425) * scaleStuff("w"), 25 * scaleStuff("h"), 400 * scaleStuff("w"), 100 * scaleStuff("h")).hit then
            screen = "mainMenu"
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

        if suit.Button("Back", (screenWidth - 425) * scaleStuff("w"), 25 * scaleStuff("h"), 400 * scaleStuff("w"), 100 * scaleStuff("h")).hit then
            screen = "mainMenu"
        end

        love.graphics.setFont(font2)

        suit.Label("No help screen yet lol", {align = "left"},
        (25 * scaleStuff("w")), (25 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
    end

    return nil
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
end

function loadAnimations(dt)
    currentAnimation = 0 -- SET TO 0 WHEN ANIMATIONS DONE!!!

    menuAnimationImages = {
        playerCar = love.graphics.newImage("Sprites/yellowcar.png"),
        policeCar = love.graphics.newImage("Sprites/yellowcar.png"),
        trafficCar = love.graphics.newImage("Sprites/yellowcar.png"),
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
            -- mac.playerImage = 
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
            -- mac.playerImage = 
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
        -- print(love.filesystem.read("saveFile.txt"))
        local str = love.filesystem.read("saveFile.txt")
        gameData = stringToTable(str)
        -- gameData["distanceTraveledHIGHSCORE"] = 100
        if gameData["distanceTraveledHIGHSCORE"] ~= nil then
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
    if not indent then indent = '' end
    local format = string.format

    local function formatValue(v)
        if type(v) == 'string' then
            return format('%q', v)
        else
            return tostring(v)
        end
    end

    local lines = {}
    table.insert(lines, "{")
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            table.insert(lines, format('%s%s = {\n%s\n%s},', indent, k, tableToString(v, indent .. '\t'), indent))
        else
            table.insert(lines, format('%s%s = %s,', indent, k, formatValue(v)))
        end
    end
    table.insert(lines, "}")
    return table.concat(lines, '\n')
end

function stringToTable(str)
    local func, err = load("return " .. str)
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
    if not indent then indent = '' end
    
    print("Save Data:")
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            print(indent .. k .. " = ")
            printTable(v, indent .. "  ")
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