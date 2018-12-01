local M = {}

local gamera = require("libs/gamera")
local utils = require("utils")

local crowd = require("game/crowd").init(M)
local bombs = require("game/bombs").init(M)

M.worldHeight = 800

local function beginContact(a, b, coll)
    local aData, bData = a:getUserData(), b:getUserData()
    col = coll
    if aData.mask[bData.group] == 'explosion' then
        M.destroyObject(utils.getFixtureId(a))
        M.destroyObject(utils.getFixtureId(b))

        x, y = a:getBody():getPosition()
        v = {x=x, y=y}
        M.futureExplosions[v] = v
    elseif aData.mask[bData.group] == 'kill' then
        M.destroyObject(utils.getFixtureId(b))
    elseif aData.mask[bData.group] == 'death' then
        M.destroyObject(utils.getFixtureId(a))
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
    M.cam = gamera.new(0, 0, 1e309, M.worldHeight)
    M.cam:setWindow(0,0,1000,500)

    M.world = love.physics.newWorld(0, 0, true)

    M.objects = {}
    M.futureExplosions = {}
    M.objectsToDestroy = {}

    crowd.createCrowd(100)
    bombs.createBomb(600, 600)

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

    doDestroy()
    startExplosions()

    M.cam:setPosition(crowd.getPosition())
end

function M.draw()
    M.cam:draw(function()
        for k, v in pairs(M.objects) do
            v.draw()
        end
        love.graphics.print("Hello", 200, 200)
    end)
end

return M