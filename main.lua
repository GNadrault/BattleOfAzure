
io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")
if arg[#arg] == "-debug" then require("mobdebug").start() end

function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

math.randomseed(love.timer.getTime())

local myMenu = require("screen/menu")
local myGame = require("screen/game")
local myFonts = require("utils/fonts")

current_scene = nil

function love.load()
  love.graphics.setFont(myFonts.mainFont)
  
  local cursor = love.mouse.newCursor("resources/images/divers/cursor.png", 0, 0)
  love.mouse.setCursor(cursor)
  largeur_ecran = love.graphics.getWidth()
  hauteur_ecran = love.graphics.getHeight()
  switchScene("menu")
end

function love.update(dt)
  if current_scene == "menu" then
    myMenu.Update(dt)
  elseif current_scene == "game" then
    myGame.Update(dt)
  end
end

function love.draw()
  if current_scene == "menu" then
    myMenu.Draw()
  elseif current_scene == "game" then
    myGame.Draw()
  end
end

function love.keypressed(key)
  if current_scene == "game" then
    myGame.KeyPressed(key)
  end
end

function love.mousepressed(x, y, button, istouch)
  if current_scene == "game" then
    myGame.MousePressed(button)
  end

end

function switchScene(scene)
  current_scene = scene
  if scene == "menu" then
    myMenu.Load()
  elseif scene == "game" then
    myGame.Load()
  end
end
  