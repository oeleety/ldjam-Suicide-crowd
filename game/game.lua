local M = {}

local gamera = require("libs/gamera")
local utils = require("utils")

local crowd = require("game/crowd").init(M)
local bombs = require("game/bombs").init(M)
local border = require("game/border").init(M)
local bear = require("game/bear").init(M)
local screaming = love.audio.newSource("game/sounds/Screaming.ogg", "static")

M.worldHeight = 800

function M.recalculateStatistics()
    M.crowdCount = crowd.updateCrowdCount()
    if M.crowdCount == 0 then
        states.changeState('highscore', {score=M.score})
    end
    x = crowd.getPosition()
    if x ~= nil then
        M.score = math.floor(math.max(x - M.initialPositionX, M.score) + 0.5)
    end
end

local function isObjectDestroyed(id)
    return M.objectsToDestroy[id] ~= nil
end

local function triggerExplosion(a, aId)
    M.destroyObject(aId)
    x, y = a:getBody():getPosition()
    v = {x=x, y=y}
    M.futureExplosions[v] = v
end

local function beginContact(a, b, coll)
    local aData, bData = a:getUserData(), b:getUserData()
    local aId, bId = utils.getFixtureId(a), utils.getFixtureId(b)
    if isObjectDestroyed(aId) or isObjectDestroyed(bId) then
        return
    end
    if aData.mask[bData.group] == 'explosion' then
        triggerExplosion(a, aId)
    elseif aData.mask[bData.group] == 'triggerExplosion' then
        triggerExplosion(b, bId)
    elseif aData.mask[bData.group] == 'kill' then
        M.destroyObject(bId)
    elseif aData.mask[bData.group] == 'death' then
        M.destroyObject(aId)
    end
end

local function doDestroy()
    for k in pairs(M.objectsToDestroy) do
        M.objectsToDestroy[k] = nil
        M.objects[k].body:destroy()
        M.objects[k] = nil
    end
end

function M.destroyObject(id)
    M.objectsToDestroy[id] = id
end

function M.load(settings)
    bombs.load()
    crowd.load()

    M.cam = gamera.new(0, 0, utils.infinity, M.worldHeight)
    M.cam:setWindow(0,0,config.windowWidth,config.windowHeight)

    M.world = love.physics.newWorld(0, 0, true)

    M.objects = {}
    M.futureExplosions = {}
    M.objectsToDestroy = {}

    crowd.createCrowd(100)
    bear.createBear(300, M.worldHeight / 2)
    border.createBorders()

    M.score = 0
    M.crowdCount = 0
    M.initialPositionX = crowd.getPosition()

    M.world:setCallbacks(beginContact)
end

local function startExplosions()
    for k, v in pairs(M.futureExplosions) do
        bombs.createExplosion(v.x, v.y)
        M.futureExplosions[k] = nil
    end
end

function M.update(dt)
    M.world:update(dt)
    for k, v in pairs(M.objects) do
        v.update(dt)
    end

    local crowdPosX, crowdPosY = crowd.getPosition()

    if crowdPosX and crowdPosY then
        local bearX, bearY = M.objects.bear.body:getPosition()
        local dX, dY = utils.normalizeVector(crowdPosX - bearX, crowdPosY - bearY)
        local maxCoef = 150
        local curCoef = math.min(M.score / 18, maxCoef)
        M.objects.bear.body:setLinearVelocity(dX * curCoef, dY * curCoef)
    end

    doDestroy()
    startExplosions()
    crowd.updateAskedPosition()
    if crowdPosX then
        bombs.createNextBombsIfNeeded(crowdPosX)
    end

    M.recalculateStatistics()
    if crowdPosX and crowdPosY then
        M.cam:setPosition(crowdPosX, crowdPosY)
    end
end

local function getSelectedForceVector(mouseX, mouseY)
    local x, y = M.cam:toWorld(mouseX, mouseY)
    local x, y = x - M.selected.body:getX(), y - M.selected.body:getY()
    return x, y
end

local function drawArrow(x1, y1, x2, y2)
    local xDiff, yDiff = utils.normalizeVector(x2 - x1, y2 - y1)
    local xN, yN = utils.normalizeVector(utils.getNormalVector(x2 - x1, y2 - y1))
    local xN, yN = xN * 8, yN * 8

    local xP, yP = x2 - 13 * xDiff, y2 - 13 * yDiff

    local xL1, yL1 = xP + xN, yP + yN
    local xL2, yL2 = xP + xN / 3, yP + yN / 3

    local xR1, yR1 = xP - xN, yP - yN
    local xR2, yR2 = xP - xN / 3, yP - yN / 3

    local xBL, yBL = x1 + xN / 3, y1 + yN / 3
    local xBR, yBR = x1 - xN / 3, y1 - yN / 3

    love.graphics.polygon("fill", x2, y2, xL1, yL1, xL2, yL2, xBL, yBL, xBR, yBR, xR2, yR2, xR1, yR1)
end

local function drawSelectedForce()
    if M.selected then
        x, y = M.selected.body:getX(), M.selected.body:getY()
        xDiff, yDiff = getSelectedForceVector(love.mouse.getPosition())

        love.graphics.setColor(0, 1, 1)
        drawArrow(x, y, xDiff + x, yDiff + y)
    end
end

local font = love.graphics.newFont(20)
local function drawHud()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    love.graphics.print('Score: ' .. tostring(M.score), 10, 10)
    text = 'Population: ' .. tostring(M.crowdCount)
    love.graphics.print(text, config.windowWidth - font:getWidth(text) - 10, 10)
end

function M.draw()
    M.cam:draw(function()
        for k, v in pairs(M.objects) do
            v.draw()
        end
        drawSelectedForce()
    end)
    drawHud()
end

function M.mousepressed(x, y, button)
    if button == 1 then
        x, y = M.cam:toWorld(x,y)
        M.selected = crowd.getGuyAt(x, y)
    elseif button == 2 then
        crowd.setAskedPosition(M.cam:toWorld(x,y))
    end
end

function M.mousereleased(x, y, button)
    if button == 1 then
        if M.selected then
            M.selected.body:setLinearVelocity(getSelectedForceVector(x, y))
            M.selected.isInCrowd = false
            screaming :play ()
            M.selected = nil
        end
    end
end

function M.keypressed(key)
    if key == 'escape' then
        states.changeState('menu')
    end
end

return M