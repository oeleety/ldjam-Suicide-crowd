local M = {}

local color= {0, 0.6, 0.4}
local colorLight= {0, 0.4, 0.4}

M.Button = {}

function M.Button:new(title, action, x, y, w, h, font)
    newObj = {
        title = title,
        action = action,
        x = x,
        y = y,
        w = w,
        h = h,
        font = font,
        isHovered = false
    }

    self.__index = self
    return setmetatable(newObj, self)
end

local function isHoveredNow(v, xMouse, yMouse)
    return xMouse >= v.x and
        xMouse <= v.x + v.w and
        yMouse >= v.y and
        yMouse <= v.y + v.h
end

function M.Button:update()
    local xMouse, yMouse = love.mouse.getPosition()
    self.isHovered = isHoveredNow(self, xMouse, yMouse)
end

function M.Button:mousepressed(x, y, button)
    if button==1 and isHoveredNow(self, x, y) then
        self.action()
    end
end

function M.Button:draw()
    love.graphics.setColor(self.isHovered and colorLight or color)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.printf(self.title, self.x, self.y + (self.h - self.font:getHeight(self.title)) / 2, self.w, 'center')
end

return M