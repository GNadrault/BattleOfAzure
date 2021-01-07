
io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")
if arg[#arg] == "-debug" then require("mobdebug").start() end

function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

math.randomseed(love.timer.getTime())

local myGame = require("game")

function love.load()
  mainFont = love.graphics.newFont("resources/fonts/Livingst.ttf", 25)
  bigFont = love.graphics.newFont("resources/fonts/Livingst.ttf", 35)
  smallFont = love.graphics.newFont("resources/fonts/Livingst.ttf", 18)
  love.graphics.setFont(mainFont)
  
  local cursor = love.mouse.newCursor("resources/images/divers/cursor.png", 0, 0)
  love.mouse.setCursor(cursor)
  largeur_ecran = love.graphics.getWidth()
  hauteur_ecran = love.graphics.getHeight()

  myGame.Load()
end


function love.update(dt)
  myGame.Update(dt)
end

function love.draw()
  myGame.Draw()
end

function love.keypressed(key)
  myGame.KeyPressed(key)
end

function love.mousepressed(x, y, button, istouch)
  myGame.MousePressed(button)
end
  