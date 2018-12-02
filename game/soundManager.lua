local M = {}

require("libs/slam")

M.Manager = {}

function M.Manager:new(sounds, duration)
    newObj = {
        sounds = sounds,
        duration = duration,
        currentTime = 0,
        prevSound = -1,
    }

    self.__index = self
    return setmetatable(newObj, self)
end

function M.Manager:update(dt)
    self.currentTime = self.currentTime + dt
    self.currentTime = math.fmod(self.currentTime, self.duration)
    local soundNum = math.floor(self.currentTime / self.duration * #self.sounds) + 1
    if self.prevSound ~= soundNum then
        self.sounds[soundNum]:play()
        self.prevSound = soundNum
    end
end

function M.Manager:reset()
    self.currentTime = 0
end

return M