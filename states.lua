local M = {}

M.allStates = {
    menu=require('menu/menu'),
    game=require('game/game'),
    highscore=require('highscore/highscore')
}

local function callIfExists(fn, ...)
    if fn then fn(...) end
end

function M.changeState(newState, settings)
    M.state = newState
    M.allStates[M.state].load(settings)
end

function M.update(dt)
    M.allStates[M.state].update(dt)
end

function M.draw()
    M.allStates[M.state].draw()
end

function M.keypressed(key)
    callIfExists(M.allStates[M.state].keypressed, key)
end

function M.mousepressed(x, y, button)
    callIfExists(M.allStates[M.state].mousepressed, x, y, button)
end

function M.mousereleased(x, y, button, istouch, presses)
    callIfExists(M.allStates[M.state].mousereleased, x, y, button, istouch, presses)
end


return M