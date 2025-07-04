local M = {}

M.Animation = {}

function M.Animation:new(image, width, height, duration)
    newObj = {
        spriteSheet = image,
        quads = {},
        duration = duration,
        currentTime = 0,
        width = width,
        height = height
    }

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(newObj.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    self.__index = self
    return setmetatable(newObj, self)
end

function M.Animation:update(dt)
    self.currentTime = self.currentTime + dt
    self.currentTime = math.fmod(self.currentTime, self.duration)
end

function M.Animation:draw(x, y)
    local spriteNum = math.floor(self.currentTime / self.duration * #self.quads) + 1
    love.graphics.draw(self.spriteSheet, self.quads[spriteNum], x - self.width / 2, y - self.height / 2)
end

function M.Animation:reset()
    self.currentTime = 0
end

return M