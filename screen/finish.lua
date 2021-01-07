local Finish = {}

local myGUI = require("utils/GUI")
local HUD = require("screen/hud")

Finish.restart = false
Finish.backToMenu = false

local groupFinishHUD
local textVictory = "VICTORY !"
local textGameover = "GAMEOVER !"
local textEndHUD = nil

function Finish.onReplayPressedHUD(pState)
  if pState == "end" then
    Finish.restart = true
  end
end

function Finish.onBackPressedHUD(pState)
  if pState == "end" then
    Finish.backToMenu = true
  end
end

function Finish.Load()
  
  -- Panel Victoire defaite + text
  local panelEndHUD = myGUI.newPanel((largeur_ecran - HUD.panelImageHUD:getWidth())/2,  hauteur_ecran/5)
  panelEndHUD:setImage(HUD.panelImageHUD)
  textEndHUD = myGUI.newText(panelEndHUD.X + 120, panelEndHUD.Y + 55, 0, 0, "", bigFont, "", "center", HUD.color3)

  -- Bouton rejouer
  local buttonReplayHUD = myGUI.newButton((largeur_ecran - HUD.buttonBlueImageHUD:getWidth())/2, hauteur_ecran - hauteur_ecran/3, 
                                HUD.buttonBlueImageHUD:getWidth(), HUD.buttonBlueImageHUD:getHeight(),"Play again", mainFont, HUD.colorPlay)
  buttonReplayHUD:setImages(HUD.buttonBlueImageHUD, HUD.buttonBlueHoverImageHUD, HUD.buttonBluePressedImageHUD)
  buttonReplayHUD:setEvent("pressed", Finish.onReplayPressedHUD)
  
--  -- Bouton quitter
  local buttonBackHUD = myGUI.newButton((largeur_ecran - HUD.buttonRedImageHUD:getWidth())/2, hauteur_ecran - hauteur_ecran/4, 
                                HUD.buttonRedImageHUD:getWidth(), HUD.buttonRedImageHUD:getHeight(),"Back to Menu", mainFont, HUD.colorExit)
  buttonBackHUD:setImages(HUD.buttonRedImageHUD, HUD.buttonRedHoverImageHUD, HUD.buttonRedPressedImageHUD)
  buttonBackHUD:setEvent("pressed", Finish.onBackPressedHUD)
  
  groupFinishHUD = myGUI.newGroup()
  groupFinishHUD:addElement(panelEndHUD)
  groupFinishHUD:addElement(textEndHUD)
  groupFinishHUD:addElement(buttonReplayHUD)
  groupFinishHUD:addElement(buttonBackHUD)
  Finish.play = false
end

function Finish.Draw()
  groupFinishHUD:draw()
end

function Finish.Update(dt, victory)
  if victory then
    textEndHUD:setText(textVictory)
  else
    textEndHUD:setText(textGameover)
  end
  groupFinishHUD:update(dt)
end

return Finish