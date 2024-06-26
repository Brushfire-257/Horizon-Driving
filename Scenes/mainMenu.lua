-- The main menu for the game
mainMenu = {}

-- SUIT setup (This is gonna make the GUI so much easier to make..)
local suit = require("suit")

-- tableIO setup (For saving)
local tableIO = require 'tableIO'

-- misc. setup
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()

local darkCurrent = 0

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
    gameData = {
        distanceTraveledHIGHSCORE,
        nearMissesHIGHSCORE,
        awesomeNearMissesHIGHSCORE,
        policeTakedownsHIGHSCORE,
        EMPDodgesHIGHSCORE,
        timeSurvivedHIGHSCORE
    }

    if firstStart == true then
        -- saveGame()
        loadGame()
        firstStart = false
    else
        saveGame()
    end

    -- Set SUIT colors
    suit.theme.color.normal.fg = {255,255,255}
    suit.theme.color.hovered = {bg = {200,230,255}, fg = {0,0,0}}
    suit.theme.color.active = {bg = {150,150,150}, fg = {0,0,0}}

    -- Load font
    -- font = love.graphics.newFont("fonts/uhh I didnt choose one yet.ttf", 100) -- The font
    -- font1 = love.graphics.newFont("fonts/I am literally on the road.ttf", 50)
    -- font2 = love.graphics.newFont("fonts/chill out bruv.ttf", 25)
    -- love.graphics.setFont(font)

    screen = "mainMenu"

    print(love.filesystem.read("saveFile.txt"))
    print(tableIO.stringToTable(love.filesystem.read("saveFile.txt")))
end

function mainMenu.update(dt)
    -- Update game data list
    gameData = {
        distanceTraveledHIGHSCORE,
        nearMissesHIGHSCORE,
        awesomeNearMissesHIGHSCORE,
        policeTakedownsHIGHSCORE,
        EMPDodgesHIGHSCORE,
        timeSurvivedHIGHSCORE
    }

    -- Prepare GUI
    if screen == "mainMenu" then
        suit.layout:reset(0, 0)

        if suit.Button("Start Game", 100, 100, 800, 150).hit then
            return "startGame"
        end

        if suit.Button("Highscores", 100, 300, 800, 150).hit then
            screen = "highscores"
        end

        if suit.Button("Quit", 100, 500, 800, 150).hit then
            love.event.quit()
        end

        -- love.graphics.setFont(font2) -- This should make it smaller when I actually add a font

        suit.Label("Made by: Logan Peterson (With LOVE)", {align = "center"}, (screenWidth - 800)/2, (screenHeight - 100), 800, 150)

        -- love.graphics.setFont(font)
    elseif screen == "highscores" then
        if suit.Button("Back", screenWidth - 425, 25, 400, 100).hit then
            screen = "mainMenu"
        end

        suit.Label("Highscores:", {align = "left"},
        (25), (25), 800, 150)
        suit.Label("Distance Traveled: " .. gameData.distanceTraveledHIGHSCORE * 0.1 / 60, {align = "left"},
        (25), (125), 800, 150)
        suit.Label("Near Misses: " .. nearMissesHIGHSCORE, {align = "left"},
        (25), (225), 800, 150)
        suit.Label("Awesome Near Misses: " .. awesomeNearMissesHIGHSCORE, {align = "left"},
        (25), (325), 800, 150)
        suit.Label("Police Takedowns: " .. policeTakedownsHIGHSCORE, {align = "left"},
        (25), (425), 800, 150)
        suit.Label("EMP Dodges: " .. EMPDodgesHIGHSCORE, {align = "left"},
        (25), (525), 800, 150)
        suit.Label("Time Survived: " .. timeSurvivedHIGHSCORE, {align = "left"},
        (25), (625), 800, 150)
    end

    return nil
end

function mainMenu.draw()
    -- Draw GUI
    suit.draw()
end

function love.keypressed(key)
    if key == "1" then -- Exit the game (Debug)
      love.event.quit()
    end
end

-- Saving system!!
function saveGame()
    local success, message = love.filesystem.write("saveFile.txt", tableIO.tableToString(gameData))
    if success then
        print("Game saved!")
        print(love.filesystem.read("saveFile.txt"))
    else
        print("Could not save game. Error: " .. message)
    end
end

function loadGame()
    if love.filesystem.getInfo("saveFile.txt") and love.filesystem.read("saveFile.txt") ~= nil then
        print(love.filesystem.read("saveFile.txt"))
        local str = love.filesystem.read("saveFile.txt")
        local str = string.gsub(str, "%z", "")  -- Remove null byte characters
        gameDatadata = stringToTable(str)
        -- gameDatadata = stringToTable(love.filesystem.read("saveFile.txt"))
        print("Game loaded!")
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

function stringToTable(str)
    local func = load("return " .. str)
    if func then
        local ok, result = pcall(func)
        if ok then
            return result
        else
            error("Failed to parse string: " .. result)
        end
    else
        error("Failed to load string!")
    end
end

return mainMenu