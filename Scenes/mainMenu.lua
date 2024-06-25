-- The main menu for the game
mainMenu = {}

-- SUIT setup (This is gonna make the GUI so much easier to make..)
local suit = require("suit")

-- misc. setup
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()

local darkCurrent = 0

function mainMenu.load()
    -- Set SUIT colors
    suit.theme.color.normal.fg = {255,255,255}
    suit.theme.color.hovered = {bg = {200,230,255}, fg = {0,0,0}}
    suit.theme.color.active = {bg = {150,150,150}, fg = {0,0,0}}

    -- Load font
    -- font = love.graphics.newFont("fonts/uhh I didnt choose one yet.ttf", 100) -- The font
    -- font1 = love.graphics.newFont("fonts/I am literally on the road.ttf", 50)
    -- font2 = love.graphics.newFont("fonts/chill out bruv.ttf", 25)
    -- love.graphics.setFont(font)
end

function mainMenu.update(dt)

    -- Prepare GUI
    suit.layout:reset(0, 0)

    if suit.Button("Start Game", 100, 100, 800, 150).hit then
        return "startGame"
    end

    if suit.Button("Quit", 100, 300, 800, 150).hit then
        love.event.quit()
    end

    -- love.graphics.setFont(font2) -- This should make it smaller when I actually add a font

    suit.Label("Made by: Logan Peterson (With LOVE)", {align = "center"}, (screenWidth - 800)/2, (screenHeight - 100), 800, 150)

    -- love.graphics.setFont(font)

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

return mainMenu