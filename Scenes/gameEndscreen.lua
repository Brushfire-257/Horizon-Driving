-- The endscreen for the arcade loop

-- Scene container
gameEndscreen = {}

-- SUIT setup
local suit = require("suit")

-- misc. setup
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()

-- Player Stats (All this stuff persists / changed to global variables)
-- local distanceTraveled = 0
-- local nearMisses = 0
-- local awesomeNearMisses = 0
-- local policeTakedowns = 0
-- local EMPDodges = 0
-- local timeSurvived = 0

function gameEndscreen.load()
    -- Set SUIT colors
    suit.theme.color.normal.fg = {255,255,255}
    suit.theme.color.hovered = {bg = {200,230,255}, fg = {0,0,0}}
    suit.theme.color.active = {bg = {150,150,150}, fg = {0,0,0}}

    -- Load font
    -- font = love.graphics.newFont("fonts/uhh I didnt choose one yet.ttf", 100) -- The font
    -- font1 = love.graphics.newFont("fonts/I am literally on the road.ttf", 50)
    -- font2 = love.graphics.newFont("fonts/chill out bruv.ttf", 25)
    -- love.graphics.setFont(font)

    -- Update Highscores
    if distanceTraveled > distanceTraveledHIGHSCORE then distanceTraveledHIGHSCORE = distanceTraveled end
    if nearMisses > nearMissesHIGHSCORE then nearMissesHIGHSCORE = nearMisses end
    if awesomeNearMisses > awesomeNearMissesHIGHSCORE then awesomeNearMissesHIGHSCORE = awesomeNearMisses end
    if policeTakedowns > policeTakedownsHIGHSCORE then policeTakedownsHIGHSCORE = policeTakedowns end
    if EMPDodges > EMPDodgesHIGHSCORE then EMPDodgesHIGHSCORE = EMPDodges end
    if timeSurvived > timeSurvivedHIGHSCORE then timeSurvivedHIGHSCORE = timeSurvived end
end

function gameEndscreen.update(dt)
    -- Prepare GUI
    suit.layout:reset(0, 0)

    if suit.Button("Continue", screenWidth - 425, 25, 400, 100).hit then
        return "mainMenu"
    end

    -- Prepare the player statistics
    suit.Label("Results", {align = "left"},
    (25), (25), 800, 150)
    suit.Label("Distance Traveled: " .. distanceTraveled * speedMultiplier / 60, {align = "left"},
    (25), (125), 800, 150)
    suit.Label("Near Misses: " .. nearMisses, {align = "left"},
    (25), (225), 800, 150)
    suit.Label("Awesome Near Misses: " .. awesomeNearMisses, {align = "left"},
    (25), (325), 800, 150)
    suit.Label("Police Takedowns: " .. policeTakedowns, {align = "left"},
    (25), (425), 800, 150)
    suit.Label("EMP Dodges: " .. EMPDodges, {align = "left"},
    (25), (525), 800, 150)
    suit.Label("Time Survived: " .. timeSurvived, {align = "left"},
    (25), (625), 800, 150)
    
    return nil
end

function gameEndscreen.draw()
    -- Draw GUI
    suit.draw()
end

function love.keypressed(key)
    if key == "1" then -- Exit the game (Debug)
      love.event.quit()
    end
end

return gameEndscreen