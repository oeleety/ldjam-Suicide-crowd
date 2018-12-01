local M = {}

local Options={
    {name='play', title='Play the game!'},
    {name='highscore', title='Highscore'},
    {name='quit', title='Quit'}
  }

function M.load(settigns)
end

function M.update(dt)

end

local height = 64
local width = 300

local startX=config.windowWidth/3
local startY=config.windowHeight/3
local delta=4

function M.mousepressed(x, y, button)
    if button == 1
    and x >= startX and x < startX + width
    and y >= startY and y < startY + height-delta
   then 
        print("game")
   end
   if button == 1
    and x >= startX and x < startX + width
    and y >= startY + height and y < startY+height*1 + height-delta
    then print("highscore")
    end
    if button == 1
    and x >= startX and x < startX + width
    and y >= startY+height*2 and y < startY+height*2 + height-delta
    then print("quick")
    end
end 


function M.draw()

    for k,v in ipairs(Options) do
        local x=startX
        local y=config.windowHeight/3+height*(k-1)
        love.graphics.setColor(0, (0.4*2*k)%1, 0.4)
        love.graphics.rectangle('fill', x, y, width, height-delta, 5, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setNewFont(30)
        love.graphics.printf(v.title, x, y, width, 'center')
    end

end

return M