local M = {}

function M.startsWith(str, start)
   return str:sub(1, #start) == start
end

function M.cartesianFromPolar(r, theta)
    return r * math.cos(theta), r * math.sin(theta)
end

function M.normalizeVector(x, y)
    local len = math.sqrt(x * x + y * y)
    return x / len, y / len
end

function M.getNormalVector(x, y)
    return -y, x
end

function M.getObjectId(o)
    return o.body:getUserData()
end

function M.getFixtureId(f)
    return f:getBody():getUserData()
end

function M.addGameObject(objects, o, getId)
    getId = getId or M.getObjectId
    objects[getId(o)] = o
end

function M.createIdGenerator(prefix)
    local cur = 0
    return function()
        cur = cur + 1
        return prefix .. tostring(cur)
    end
end

return M
