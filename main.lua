-- It begins.

-- Get the game running on computer then port over to android. (No iphone, too much work...)

-- Game version
gameVersion = 0.2

-- Hold the current state of the game
local state = {}

-- Load libraries
local CScreen = require "cscreen"
local splash = require("splashes.o-ten-one")

local splashDone = 0

-- misc. setup (Planning on adding intro later)
firstStart = true -- After intro set this to false

-- Define the load function
function love.load()
    -- Load window values
    love.window.setFullscreen(true)
    local screen_width = 2340/2 --love.graphics.getWidth() -- Goofy things to get the splash screen working with other GUI
    local screen_height = 1080/2 --love.graphics.getHeight()

    love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight()) -- Set to 1920 x 1080 on launch

    love.window.setFullscreen(true)

    -- love.window.setMode(2340/2, 1080/2) -- Set to custom w / h for debug

    love.window.setTitle("Horizon Driving")
    love.math.setRandomSeed(os.time())

    -- Load scaling
    -- CScreen.init(1920, 1080, true)

    -- Load High Scores
    -- loadHighscores()

    splash = splash.new()
    splash.onDone = function()
        splashDone = 1
        print("Splash screen done!")
        -- Load the menu state
        state.current = require("Scenes/mainMenu")
        state.current.load()
    end
end

function love.update(dt) -- Runs every frame.
    -- Update the current state

    print("FPS: " .. love.timer.getFPS())

    if splashDone == 0 then
        splash:update(dt)
    else
        local nextState = state.current.update(dt)
        if nextState == "startGame" then
            -- Switch to the game scene
            print("Switching to the arcade game scene")
            state.current = require("Scenes/game")
            state.current.load()
        elseif nextState == "gameEndscreen" then
            -- Switch to the game endscreen
            print("Switching to the arcade game endscreen")
            state.current = require("Scenes/gameEndscreen")
            state.current.load()
        elseif nextState == "mainMenu" then
            -- Switch to the main menu scene
            print("Switching to the main menu scene")
            state.current = require("Scenes/mainMenu")
            state.current.load()
        elseif nextState == "playerDeath" then
            -- Switch to the player death scene
            print("Switching to the player death scene")
            state.current = require("Scenes/playerDeath")
            state.current.load()
        end
    end
end

function love.draw() -- Draws every frame / Runs directly after love.update()
    
    if splashDone == 1 then
        love.graphics.clear(27/255, 26/255, 50/255)
        -- Set the scaling
        -- CScreen.apply()
        -- Draw the current state
        state.current.draw()
        -- CScreen.cease()
    else
        splash:draw()
    end
end

function love.keypressed()
    splash:skip()
end

-- Scaling Function
function love.resize(width, height)
	CScreen.update(width, height)
end