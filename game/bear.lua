local M = {}

local utils = require("utils")
local animation = require("game/animation")
local imageBear = love.graphics.newImage("game/images/enemy.png")

function M.init(game)
    M.game = game
    return M
end

local function createBearObj(x, y)
    local res = {}
    res.body = love.physics.newBody(M.game.world, x, y, "dynamic")
    res.shape = love.physics.newRectangleShape(100, 200)
    res.fixture = love.physics.newFixture(res.body, res.shape)
    res.animation = animation.Animation:new(imageBear, 100, 200, 1)

    res.body:setUserData('bear')
    res.fixture:setUserData({ group='bear', mask={ bombs='triggerExplosion', human='kill' }})

    function res.draw()
        love.graphics.setColor(1, 1, 1)
        res.animation:draw(res.body:getX(), res.body:getY())
    end
    function res.update(dt)
        res.animation:update(dt)
    end
    return res;
end

function M.createBear(x, y)
    utils.addGameObject(M.game.objects, createBearObj(x, y))
end

return M
