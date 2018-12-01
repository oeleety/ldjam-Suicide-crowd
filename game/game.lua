local M = {}

function M.load(settings)
    M.world = love.physics.newWorld(0, 0, true)
    M.objects = {
        crowd = require("game/crowd")
    }
    M.objects.crowd.create(M.world, 20)
end

function M.update(dt)
    M.world:update(dt)
    for k, v in pairs(M.objects) do
        v.update(dt)
    end
end

function M.draw()
    for k, v in pairs(M.objects) do
        v.draw()
    end
end

return M