local M = {}

local utils = require("utils")

local bombIdGen = utils.createIdGenerator('bomb')
local explosionIdGen = utils.createIdGenerator('explosion')

function M.init(game)
    M.game = game
    return M
end

local function createBombObj(x, y)
    local res = {}
    res.body = love.physics.newBody(M.game.world, x, y)
    res.shape = love.physics.newCircleShape(15)
    res.fixture = love.physics.newFixture(res.body, res.shape)
    res.fixture:setSensor(true)

    res.body:setUserData(bombIdGen())
    res.fixture:setUserData({ group='bombs', mask={ human='explosion' }})

    function res.draw()
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", res.body:getX(), res.body:getY(), res.shape:getRadius())
    end
    function res.update(dt) end
    return res;
end

function M.createBomb(x, y)
    utils.addGameObject(M.game.objects, createBombObj(x, y))
end

local function createExplosionPart(x, y, xCenter, yCenter)
    local timeCreated = love.timer.getTime()

    local res = {}
    res.body = love.physics.newBody(M.game.world, x, y, 'dynamic')
    res.shape = love.physics.newCircleShape(5)
    res.fixture = love.physics.newFixture(res.body, res.shape)
    res.fixture:setSensor(true)

    res.body:setUserData(explosionIdGen())
    res.fixture:setUserData({ group='explosionPart', mask={ human='kill' }})

    xDiff, yDiff = utils.normalizeVector(x - xCenter, y - yCenter)
    res.body:setLinearVelocity(xDiff * love.math.random(100, 500), yDiff * love.math.random(100, 500));

    function res.draw()
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle("fill", res.body:getX(), res.body:getY(), res.shape:getRadius())
    end
    function res.update(dt)
        if love.timer.getTime() - timeCreated > 0.2 then
            M.game.destroyObject(utils.getObjectId(res))
        end
    end

    return res;
end

function M.createExplosion(x, y)
    for i = 0, 50 do
        xPart, yPart = utils.cartesianFromPolar(love.math.random(0.1, 10), (i / 50) * 2 * math.pi)
        utils.addGameObject(M.game.objects, createExplosionPart(x + xPart, y + yPart, x, y))
    end
end

return M