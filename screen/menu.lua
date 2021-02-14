local Menu = {}

local myGUI = require("utils/GUI")
local HUD = require("utils/hud")
local Fonts = require("utils/fonts")

local music = nil
local groupMenuHUD
local showMenu = false
local titre = {}
local fond = {}

function Menu.onPlayPressedHUD(pState)
  if pState == "end" then
    switchScene("game")
    music:stop()
  end
end

function Menu.onExitPressedHUD(pState)
  love.event.quit()
end

function Menu.Load()
  fond.image = love.graphics.newImage("resources/images/menu/fond.png")
  fond.width = fond.image:getWidth()
  fond.height = fond.image:getHeight()
  
  titre.speed = 30
  titre.image = love.graphics.newImage("resources/images/menu/titre.png")
  titre.width = titre.image:getWidth()
  titre.height = titre.image:getHeight()
  titre.x = (largeur_ecran - titre.width)/2
  titre.y = -(titre.height + 5)
  
  music = love.audio.newSource("resources/sons/TownTheme.mp3","static")
  music:setVolume(0.5)
  music:setLooping(true)
  
  -- Bouton jouer
  local buttonPlayHUD = myGUI.newButton((largeur_ecran - HUD.buttonBlueImageHUD:getWidth())/2, hauteur_ecran - hauteur_ecran/3, 
                                HUD.buttonBlueImageHUD:getWidth(), HUD.buttonBlueImageHUD:getHeight(),"Play", Fonts.mainFont, HUD.colorPlay)
  buttonPlayHUD:setImages(HUD.buttonBlueImageHUD, HUD.buttonBlueHoverImageHUD, HUD.buttonBluePressedImageHUD)
  buttonPlayHUD:setEvent("pressed", Menu.onPlayPressedHUD)
  
  -- Bouton quitter
  local buttonExitHUD = myGUI.newButton((largeur_ecran - HUD.buttonRedImageHUD:getWidth())/2, hauteur_ecran - hauteur_ecran/4, 
                                HUD.buttonRedImageHUD:getWidth(), HUD.buttonRedImageHUD:getHeight(),"Exit", Fonts.mainFont, HUD.colorExit)
  buttonExitHUD:setImages(HUD.buttonRedImageHUD, HUD.buttonRedHoverImageHUD,HUD. buttonRedPressedImageHUD)
  buttonExitHUD:setEvent("pressed", Menu.onExitPressedHUD)
  
  groupMenuHUD = myGUI.newGroup()
  groupMenuHUD:addElement(buttonPlayHUD)
  groupMenuHUD:addElement(buttonExitHUD)
  
  showMenu = false
  music:play()
end


function Menu.Draw()
  love.graphics.draw(fond.image, (largeur_ecran - fond.width)/2, 0)
  love.graphics.draw(titre.image, titre.x, titre.y)
  if showMenu then
    groupMenuHUD:draw()
  end
end

function Menu.Update(dt)
  titre.y = titre.y + titre.speed * dt
  if titre.y >= hauteur_ecran/5 then
    titre.y = hauteur_ecran/5
    showMenu = true
  end
  if showMenu then
    groupMenuHUD:update(dt)
  end
end

return Menu