local M = {}

utils = require("utils")

local itemIdGen = utils.createIdGenerator('human')

local function moveItem(item, force)
    if love.keyboard.isDown('w') then item.body:applyForce(0, -force) end
    if love.keyboard.isDown('a') then item.body:applyForce(-force, 0) end
    if love.keyboard.isDown('s') then item.body:applyForce(0, force) end
    if love.keyboard.isDown('d') then item.body:applyForce(force, 0) end
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
        if res.isInCrowd then moveItem(res, 2000 * dt) end
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
    x, y = 0, 0
    count = 0
    for k, v in pairs(M.game.objects) do
        if utils.startsWith(k, 'human') then
            bx, by = v.body:getPosition()
            x = x + bx
            y = y + by
            count = count + 1
        end
    end
    return x / count, y / count
end

function M.getGuyAt(x, y)
    for k, v in pairs(M.game.objects) do
        if utils.startsWith(k, 'human') and v.isInCrowd then
            if v.fixture:testPoint(x, y) then
                return v
            end
        end
    end
    return nil
end

return M