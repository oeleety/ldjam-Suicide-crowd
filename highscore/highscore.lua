local M = {}

local button = require("button")

local topScores = {}
local currentScore = nil
local font = love.graphics.newFont(40)
local buttonsFont = love.graphics.newFont(30)

local function getText()
    local text = ''
    local count = 0
    if currentScore then
        text = text .. 'Your score: ' .. tostring(currentScore) .. '\n\n'
        count = count + 2
    end

    if #topScores ~= 0 then
        text = text .. 'Highscores:\n\n'
        count = count + 2
        for i, v in ipairs(topScores) do
            text = text .. tostring(i) .. '. ' .. tostring(v) .. '\n'
            count = count + 1
        end
    else
        text = text .. 'You have no highscores yet\n\nGo earn some!\n'
        count = count + 3
    end
    return text, count
end

local function updateTopScores(score)
    table.insert(topScores, score)
    table.sort(topScores, function(a, b) return a > b end)
    if #topScores > 10 then
        table.remove(topScores)
    end
end

function M.load(settings)
    currentScore = settings and settings.score
    if currentScore then
        updateTopScores(currentScore)
    end

    M.text, M.lines = getText()
    M.w, M.h = font:getWidth(M.text), font:getHeight(M.text) * M.lines
    M.w = math.max(M.w, 500)
    M.x, M.y = (config.windowWidth - M.w) / 2, (config.windowHeight - M.h) / 2

    local width = 200
    local buttonsY = M.y + M.h + 20
    local buttonsXLeft = M.x
    local buttonsXRight = M.x + M.w - width

    M.buttons = {
        button.Button:new('Restart',
            function() states.changeState('game') end,
            buttonsXLeft, buttonsY,
            width, 60, buttonsFont),
        button.Button:new('Menu',
            function() states.changeState('menu') end,
            buttonsXRight, buttonsY,
            width, 60, buttonsFont)
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

function M.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    love.graphics.printf(M.text, M.x, M.y, M.w, 'center')
    for k,v in ipairs(M.buttons) do
        v:draw()
    end
end

function M.keypressed(key)
    if key == 'escape' then
        states.changeState('menu')
    end
end

return M