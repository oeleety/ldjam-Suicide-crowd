local M = {}

local utils = require("utils")

local itemIdGen = utils.createIdGenerator('human')

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

        if sumDist / count < count / 2 then
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

    res.body:setUserData(itemIdGen())
    res.fixture:setUserData({ group='human', mask={ bombs='explosion', explosionPart='death' }})

    res.isInCrowd = true

    function res.draw()
        love.graphics.setColor(1, 1, 1)
        love.graphics.polygon("fill", res.body:getWorldPoints(res.shape:getPoints())) 
    end
    function res.update(dt)
        if res.isInCrowd then moveItem(res, dt) end
    end
    return res
end

function M.init(game)
    M.game = game
    return M
end

function M.createCrowd(count)
    for i = 1, count do
        x, y = love.math.random(-10, 10), love.math.random(-20, 20)
        utils.addGameObject(M.game.objects, createItem(config.windowWidth/2 + x, M.game.worldHeight/2 + y))
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