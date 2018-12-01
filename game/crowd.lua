local M = {}

M.items = {}
local force = 2000

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
    function res.draw()
        love.graphics.setColor(1, 1, 1)
        love.graphics.polygon("fill", res.body:getWorldPoints(res.shape:getPoints())) 
    end
    function res.update(dt)
        moveItem(res, force * dt)
    end
    return res;
end

local function addItem(item)
    item.fixture:setUserData(M.nextItemNum)
    M.items[M.nextItemNum] = item 
    M.nextItemNum = M.nextItemNum + 1
end

function M.create(game, count)
    M.game = game
    M.nextItemNum = 0
    for i = 1, count do
        x, y = love.math.random(-10, 10), love.math.random(-20, 20)
        addItem(createItem(config.windowWidth/2 + x, game.worldHeight/2 + y))
    end
end

function M.update(dt)
    for _, v in pairs(M.items) do
        v.update(dt)
    end
end

function M.draw()
    for _, v in pairs(M.items) do
        v.draw()
    end
end

function M.getPosition()
    x, y = 0, 0
    count = 0
    for _, v in pairs(M.items) do
        x1, y1 = v.body:getPosition()
        x = x + x1
        y = y + y1
        count = count + 1
    end
    return x / count, y / count
end

return M