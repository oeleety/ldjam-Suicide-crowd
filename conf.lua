config = {}
config.windowWidth = 1000
config.windowHeight = 500

function love.conf(t)
    t.window.title = "Coolest game ever"
    t.window.width = config.windowWidth
    t.window.height = config.windowHeight
    t.console = true
end
