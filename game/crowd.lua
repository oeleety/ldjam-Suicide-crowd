local M = {}

require("libs/slam")

local utils = require("utils")
local animation = require("game/animation")
local soundManager = require("game/soundManager")

local itemIdGen = utils.createIdGenerator('human')
local image = love.graphics.newImage("game/images/human.png")

local sounds = {
    love.audio.newSource("game/sounds/step_cloth1.ogg", "static"),
    love.audio.newSource("game/sounds/step_cloth2.ogg", "static"),
    love.audio.newSource("game/sounds/step_cloth3.ogg", "static"),
    love.audio.newSource("game/sounds/step_cloth4.ogg", "static"),
}

local function iterateOverCrowd(fn, includeAll)
    for k, v in pairs(M.game.objects) do
        if utils.startsWith(k, 'human') and (includeAll or v.isInCrowd) then
            r = fn(v)
            if r then return r end
        end
    end
    return nil
end

function M.setAskedPosition(x, y)
    M.askedPosition = {x = x, y = y}
end

function M.updateAskedPosition()
    if M.askedPosition then
        local xA = M.askedPosition.x
        local yA = M.askedPosition.y

        local sumDist = 0
        local count = 0
        iterateOverCrowd(function(v)
            local x, y = v.body:getPosition()
            sumDist = sumDist + utils.getVectorLen(x - xA, y - yA)
            count = count + 1
        end)

        if sumDist / count < count / 1.3 then
            M.askedPosition = nil
        end
    end
end

local function moveItem(item, dt)
    if M.askedPosition then
        local x, y = item.body:getPosition()
        local xDiff, yDiff = utils.normalizeVector(M.askedPosition.x - x, M.askedPosition.y - y)
        local c = dt * 3000 * math.pow(M.count, 1/3)
        item.body:setLinearVelocity(xDiff * c, yDiff * c)
    else
        item.body:setLinearVelocity(0, 0)
    end
end

local function createItem(x, y)
    local res = {}
    res.body = love.physics.newBody(M.game.world, x, y, "dynamic")
    res.body:setFixedRotation(true)
    res.shape = love.physics.newRectangleShape(10, 15)
    res.fixture = love.physics.newFixture(res.body, res.shape, 0.1)
    res.animation = animation.Animation:new(image, 10, 15, 0.3)
    res.sounds = soundManager.Manager:new(sounds, love.math.random(0.5, 1))

    res.body:setUserData(itemIdGen())
    res.fixture:setUserData({ group='human', mask={ bombs='triggerExplosion', explosionPart='death', bear='death' }})

    res.isInCrowd = true

    function res.draw()
        love.graphics.setColor(1, 1, 1)
        res.animation:draw(res.body:getX(), res.body:getY())
    end
    function res.update(dt)
        velX, velY = res.body:getLinearVelocity()
        if math.abs(velX) > 0.01 or math.abs(velY) > 0.01 then
            res.animation:update(dt)
            res.sounds:update(dt)
        else
            res.animation:reset()
            res.sounds:reset()
        end
        if res.isInCrowd then moveItem(res, dt) end
    end
    return res
end

function M.init(game)
    M.game = game
    return M
end

function M.load()
    M.askedPosition = nil
end

function M.createCrowd(count)
    for i = 1, count do
        x, y = love.math.random(-10, 10), love.math.random(-20, 20)
        utils.addGameObject(M.game.objects, createItem(1000 + x, M.game.worldHeight/2 + y))
    end
end

function M.getPosition()
    local x, y = 0, 0
    local count = 0
    iterateOverCrowd(function(v)
        bx, by = v.body:getPosition()
        x = x + bx
        y = y + by
        count = count + 1
    end)
    if count == 0 then
        return nil, nil
    else
        return x / count, y / count
    end
end

function M.getGuyAt(x, y)
    return iterateOverCrowd(function(v)
        if v.fixture:testPoint(x, y) then
            return v
        end
    end)
end

function M.updateCrowdCount()
    M.count = 0
    iterateOverCrowd(function() M.count = M.count + 1 end)
    return M.count
end

return M