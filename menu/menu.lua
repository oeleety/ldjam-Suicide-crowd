local M = {}

local button = require("button")

local height = 64
local width = 300
local delta=4
local font = love.graphics.newFont(30)

function M.load(settigns)

    local x1=config.windowWidth/2 - width/2
    local x2=config.windowWidth/2 + width/2
    M.startY = (config.windowHeight - 3 * height) / 2
    M.buttons = {
        button.Button:new('Play the game!',
            function() states.changeState('game') end,
            x1, M.startY,
            width, height - delta, font),
        button.Button:new('Highscore',
            function() states.changeState('highscore') end,
            x1, M.startY+height,
            width, height - delta, font),
        button.Button:new('Exit',
            function() love.event.quit() end,
            x1, M.startY+2*height,
            width, height - delta, font)
    }
end

function M.update(dt)
    for k,v in ipairs(M.buttons) do
        v:update(dt)
    end
end

function M.mousepressed(x, y, button)
    for k,v in ipairs(M.buttons) do
        v:mousepressed(x, y, button)
    end
end

function M.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

local textFont = love.graphics.newFont(60)
function M.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(textFont)
    local text = "Suicide Crowd"
    love.graphics.print(text,
        (config.windowWidth - textFont:getWidth(text)) / 2,
        M.startY - 50 - textFont:getHeight(text))

    for k,v in ipairs(M.buttons) do
        v:draw()
    end
end

return M