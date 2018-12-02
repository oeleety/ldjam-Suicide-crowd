local M = {}

M.infinity=1e6

function M.startsWith(str, start)
   return str:sub(1, #start) == start
end

function M.cartesianFromPolar(r, theta)
    return r * math.cos(theta), r * math.sin(theta)
end

function M.getVectorLen(x, y)
    return math.sqrt(x * x + y * y)
end

function M.normalizeVector(x, y)
    local len = M.getVectorLen(x, y)
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
                                                                       --cam                      -- border
                                                                  --l,t         l+w,t=x2,y2      x,y            x+bW,y=x4,y4
function M.findCross(l, t, w, h, x, y, borderWidth, borderHeight) --l,t+h=x1,y1  l+w,t+h         x,y+bH =x3,y3  x+bW,y+bH
    local x1, y1 = l,t+h
    local x2, y2 = l+w,t
    local x3, y3 = x, y+borderHeight
    local x4, y4 = x+borderWidth,y

    local left = math.max(x1,x3)
    local right = math.min(x2,x4)
    local top = math.max(y2,y4)
    local bottom = math.min(y1,y3)

    --print( "l= ", l, " t= ", t, " w= ", w ," h= ", h ," x= ", x , " y= ", y ," bW= " ,  borderWidth ," b= H" , borderHeight)
    --print("left=", left , " right=", right , " top=", top , " bottom=", bottom)
    

    local width=right-left
    local heigh=bottom-top
    --print(width, heigh)

    return left, top, width, heigh

end

return M
