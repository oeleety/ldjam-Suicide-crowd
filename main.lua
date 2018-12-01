
states = require("states")

function love.keypressed(key)
end

function love.load()
    states.changeState('menu')
end

function love.update(dt)
    states.update(dt)
end

function love.draw()
    states.draw()
end