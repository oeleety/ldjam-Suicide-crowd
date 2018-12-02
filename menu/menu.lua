local M = {}

local height = 64
local width = 300
local delta=4
local color= {0, 0.6, 0.4}
local colorLight= {0, 0.4, 0.4}


function M.load(settigns)
    local x1=config.windowWidth/2 - width/2
    local x2=config.windowWidth/2 + width/2
    M.Options={
        {name='play', title='Play the game!', 
        x1=x1, x2=x2,
        y1=config.windowHeight/3,
        y2=config.windowHeight/3+height-delta,
        color=color,
        colorLight=colorLight,
        isHovered=false,
        action=function() states.changeState('game') end}, 

        {name='highscore', title='Highscore',
        x1=x1, x2=x2,
        y1=config.windowHeight/3+height,
        y2=config.windowHeight/3+2*height-delta,
        color=color,
        colorLight=colorLight,
        isHovered=false,
        action=function() states.changeState('highscore') end},

        {name='quit', title='Quit',
        x1=x1, x2=x2,
        y1=config.windowHeight/3+2*height,
        y2=config.windowHeight/3+3*height-delta,
        color=color,
        colorLight=colorLight,
        isHovered=false,
        action=function() love.event.quit() end}
    }
end

function isHoveredNow(k)
    local xMouse, yMouse = love.mouse.getPosition()
        if xMouse >= k.x1 and xMouse <= k.x2
            and yMouse >= k.y1 and yMouse <= k.y2
        then out=true
        else out=false
        end
    return out
end

function M.update(dt)
    for k,v in ipairs(M.Options) do
        v.isHovered = isHoveredNow(v)
    end

end

function M.mousepressed(x, y, button)
    for k,v in ipairs(M.Options) do
        if button==1
        and x >= v.x1 and x < v.x2
        and y >= v.y1 and y < v.y2
        then    
            v.action()
        end
    end
end    

local font = love.graphics.newFont(30)
function M.draw()
    for k,v in ipairs(M.Options) do
        love.graphics.setColor(v.isHovered and colorLight or color)
        love.graphics.rectangle('fill', v.x1, v.y1, width, height-delta, 5, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(font)
        love.graphics.printf(v.title, v.x1, (v.y1 + v.y2 - font:getHeight(v.title)) / 2, width, 'center')
    end
end

return M