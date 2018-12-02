local M = {}

local utils = require("utils")
local animation = require("game/animation")

local bombIdGen = utils.createIdGenerator('bomb')
local explosionIdGen = utils.createIdGenerator('explosion')
local imageBomb = love.graphics.newImage("game/images/bomb.png")

function M.init(game)
    M.game = game
    return M
end

function M.load()
    M.lastBombsX = 700
end

local function createBombObj(x, y)
    local res = {}
    res.body = love.physics.newBody(M.game.world, x, y)
    res.shape = love.physics.newCircleShape(12)
    res.fixture = love.physics.newFixture(res.body, res.shape)
    res.fixture:setSensor(true)
    res.animation = animation.Animation:new(imageBomb, 12, 12, 1)

    res.body:setUserData(bombIdGen())
    res.fixture:setUserData({ group='bombs', mask={ human='explosion', explosionPart='explosion' }})

    function res.draw()
        love.graphics.setColor(1, 1, 1)
        res.animation:draw(res.body:getX(), res.body:getY())
    end
    function res.update(dt)
        res.animation:update(dt)
    end
    return res;
end

function M.createBomb(x, y)
    utils.addGameObject(M.game.objects, createBombObj(x, y))
end

local function createExplosionPart(x, y, xCenter, yCenter)
    local timeCreated = love.timer.getTime()

    local res = {}
    res.body = love.physics.newBody(M.game.world, x, y, 'dynamic')
    res.shape = love.physics.newCircleShape(2.5)
    res.fixture = love.physics.newFixture(res.body, res.shape)
    res.fixture:setSensor(true)

    res.body:setUserData(explosionIdGen())
    res.fixture:setUserData({ group='explosionPart', mask={ human='kill', bombs='kill' }})

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
    for i = 0, 60 do
        xPart, yPart = utils.cartesianFromPolar(love.math.random(0.1, 10), (i / 50) * 2 * math.pi)
        utils.addGameObject(M.game.objects, createExplosionPart(x + xPart, y + yPart, x, y))
    end
end

-- TODO: increase number of bombs with time
local function createNextBombs(leftX, rightX, number)
    local top = 50
    local bottom = M.game.worldHeight - 50

    for i = 1, number do
        M.createBomb(love.math.random(leftX, rightX), love.math.random(top, bottom))
    end
end

function M.createNextBombsIfNeeded(crowdPosX)
    if M.lastBombsX - crowdPosX < 1000 then
        createNextBombs(M.lastBombsX, M.lastBombsX + 1000, 50)
        M.lastBombsX = M.lastBombsX + 1000
    end
end

return M