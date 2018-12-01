local utils = require("utils")

local M = {}

local borderIdGen = utils.createIdGenerator('border')

function M.init(game)
    M.game = game
    return M
end

local function createBorder(x,y)
    local res = {}
    res.body=love.physics.newBody(M.game.world, x,y)
    res.shape = love.physics.newRectangleShape(1000, 100)
    res.fixture = love.physics.newFixture(res.body, res.shape)

    res.body:setUserData(borderIdGen())
    res.fixture:setUserData({ group='border', mask={ bombs='explosion', explosionPart='death' }})

    function res.draw()
        love.graphics.setColor(0.5, 1, 1)
        love.graphics.polygon("fill", res.body:getWorldPoints(res.shape:getPoints()))
    end
    function res.update(dt) end--??
    return res
end

function M.createBorder(x, y)
    utils.addGameObject(M.game.objects, createBorder(x, y))
end

return M


