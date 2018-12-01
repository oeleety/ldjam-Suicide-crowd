local M = {}

M.allStates = {
    menu=require('menu/menu'),
    game=require('game/game'),
    highscore=require('highscore/highscore')
}

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

function M.mousepressed(x, y, button)
    M.allStates[M.state].mousepressed(x, y, button)
end

return M