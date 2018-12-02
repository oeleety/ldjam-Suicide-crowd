local utils = require("utils")

local M = {}

local borderIdGen = utils.createIdGenerator('border')

function M.init(game)
    M.game = game
    return M
end

local function createBorder(x,y,borderWidth,borderHeight)
    local res = {}
    res.body=love.physics.newBody(M.game.world, x+borderWidth/2,y+borderHeight/2)
    res.shape = love.physics.newRectangleShape(borderWidth, borderHeight)
    res.fixture = love.physics.newFixture(res.body, res.shape)

    res.body:setUserData(borderIdGen())
    res.fixture:setUserData({ group='border', mask={}})

    function res.draw()
        love.graphics.setColor(0, 0.8, 0.4)
        local l, t, w, h = M.game.cam:getVisible()
        love.graphics.rectangle("fill", utils.findCross(l,t,w,h, x, y,borderWidth, borderHeight))
    end
    function res.update(dt) end
    return res
end

function M.createBorders()
    borderHeight=30
    
    utils.addGameObject(M.game.objects, createBorder(0, 0, utils.infinity,borderHeight))
    utils.addGameObject(M.game.objects, createBorder(0, M.game.worldHeight-borderHeight, utils.infinity, borderHeight))
    utils.addGameObject(M.game.objects, createBorder(0, 0, borderHeight, M.game.worldHeight))
end

return M
