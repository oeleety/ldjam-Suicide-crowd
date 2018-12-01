local M = {}

local gamera = require("libs/gamera")

M.worldHeight = 800

function M.load(settings)
    M.cam = gamera.new(0, 0, 1e309, M.worldHeight)
    M.cam:setWindow(0,0,1000,500)

    M.world = love.physics.newWorld(0, 0, true)
    M.objects = {
        crowd = require("game/crowd")
    }
    M.objects.crowd.create(M, 20)
end

function M.update(dt)
    M.world:update(dt)
    for k, v in pairs(M.objects) do
        v.update(dt)
    end
    M.cam:setPosition(M.objects.crowd.getPosition())
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