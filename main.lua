
states = require("states")
config = {}

function love.keypressed(key)
    states.keypressed(key)
end

function love.mousepressed(x,y,button)
    states.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button, istouch, presses)
    states.mousereleased(x, y, button, istouch, presses)
end

function love.load()
    config.windowWidth = love.graphics.getWidth()
    config.windowHeight = love.graphics.getHeight()

    states.changeState('menu')
end

function love.update(dt)
    states.update(dt)
end

function love.draw()
    states.draw()
end