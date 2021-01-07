local Menu = {}

local myGUI = require("utils/GUI")
local HUD = require("screen/hud")

Menu.play = false
Menu.music = nil

local groupMenuHUD
local showMenu = false
local titre = {}
local fond = {}
local wind = nil

function Menu.onPlayPressedHUD(pState)
  if pState == "end" then
    Menu.play = true
    wind:play()
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
  
  Menu.music = love.audio.newSource("resources/sons/TownTheme.mp3","static")
  Menu.music:setVolume(0.5)
  Menu.music:setLooping(true)
  
  wind = love.audio.newSource("resources/sons/wind.ogg","static")
  wind:setVolume(0.5)
  
  -- Bouton jouer
  local buttonPlayHUD = myGUI.newButton((largeur_ecran - HUD.buttonBlueImageHUD:getWidth())/2, hauteur_ecran - hauteur_ecran/3, 
                                HUD.buttonBlueImageHUD:getWidth(), HUD.buttonBlueImageHUD:getHeight(),"Play", mainFont, HUD.colorPlay)
  buttonPlayHUD:setImages(HUD.buttonBlueImageHUD, HUD.buttonBlueHoverImageHUD, HUD.buttonBluePressedImageHUD)
  buttonPlayHUD:setEvent("pressed", Menu.onPlayPressedHUD)
  
  -- Bouton quitter
  local buttonExitHUD = myGUI.newButton((largeur_ecran - HUD.buttonRedImageHUD:getWidth())/2, hauteur_ecran - hauteur_ecran/4, 
                                HUD.buttonRedImageHUD:getWidth(), HUD.buttonRedImageHUD:getHeight(),"Exit", mainFont, HUD.colorExit)
  buttonExitHUD:setImages(HUD.buttonRedImageHUD, HUD.buttonRedHoverImageHUD,HUD. buttonRedPressedImageHUD)
  buttonExitHUD:setEvent("pressed", Menu.onExitPressedHUD)
  
  groupMenuHUD = myGUI.newGroup()
  groupMenuHUD:addElement(buttonPlayHUD)
  groupMenuHUD:addElement(buttonExitHUD)
  Menu.play = false
end

function Menu.Start()
  Menu.play = false
  showMenu = false
  Menu.music:play()
  titre.x = (largeur_ecran - titre.width)/2
  titre.y = -(titre.height + 5)
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