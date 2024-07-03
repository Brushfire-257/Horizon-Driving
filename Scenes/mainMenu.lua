-- The main menu for the game
mainMenu = {}

-- SUIT setup (This is gonna make the GUI so much easier to make..)
local suit = require("suit")

-- tableIO setup (For saving)
local tableIO = require 'tableIO'

-- misc. setup
local screenWidthA = love.graphics.getWidth()
local screenHeightA = love.graphics.getHeight()
local screenWidth = 1920
local screenHeight = 1080

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
    -- gameData = {
    --     distanceTraveledHIGHSCORE,
    --     nearMissesHIGHSCORE,
    --     awesomeNearMissesHIGHSCORE,
    --     policeTakedownsHIGHSCORE,
    --     EMPDodgesHIGHSCORE,
    --     timeSurvivedHIGHSCORE
    -- }

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
    -- print(tableIO.stringToTable(love.filesystem.read("saveFile.txt")))
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

    -- Prepare GUI
    if screen == "mainMenu" then
        suit.layout:reset(0, 0)

        love.graphics.setFont(font)

        if suit.Button("Start Game", 100 * scaleStuff("w"), 100 * scaleStuff("h"),
        800 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
            return "startGame"
        end

        if suit.Button("Highscores", 100 * scaleStuff("w"), 300 * scaleStuff("h"),
        800 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
            screen = "highscores"
        end

        if suit.Button("Quit", 100 * scaleStuff("w"), 500 * scaleStuff("h"),
        800 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
            love.event.quit()
        end

        love.graphics.setFont(font2)

        suit.Label("Made by: Logan Peterson (With LOVE)", {align = "center"}, ((screenWidth - 800)/2) * scaleStuff("w"), (screenHeight - 150) * scaleStuff("h"), 800 * scaleStuff("w"), 150 * scaleStuff("h"))

    elseif screen == "highscores" then
        if suit.Button("Back", (screenWidth - 425) * scaleStuff("w"), 25 * scaleStuff("h"), 400 * scaleStuff("w"), 100 * scaleStuff("h")).hit then
            screen = "mainMenu"
        end

        love.graphics.setFont(font2)

        suit.Label("Highscores:", {align = "left"},
        (25 * scaleStuff("w")), (25 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
        suit.Label("Distance Traveled: " .. gameData.distanceTraveledHIGHSCORE * 0.1 / 60, {align = "left"},
        (25 * scaleStuff("w")), (125 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
        suit.Label("Near Misses: " .. gameData.nearMissesHIGHSCORE, {align = "left"},
        (25 * scaleStuff("w")), (225 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
        suit.Label("Awesome Near Misses: " .. gameData.awesomeNearMissesHIGHSCORE, {align = "left"},
        (25 * scaleStuff("w")), (325 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
        suit.Label("Police Takedowns: " .. gameData.policeTakedownsHIGHSCORE, {align = "left"},
        (25 * scaleStuff("w")), (425 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
        suit.Label("EMP Dodges: " .. gameData.EMPDodgesHIGHSCORE, {align = "left"},
        (25 * scaleStuff("w")), (525 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
        suit.Label("Time Survived: " .. gameData.timeSurvivedHIGHSCORE, {align = "left"},
        (25 * scaleStuff("w")), (625 * scaleStuff("h")), 800 * scaleStuff("w"), 150 * scaleStuff("h"))
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