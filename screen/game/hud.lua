local HUD = {}

HUD.boxImageHUD = love.graphics.newImage("resources/images/hud/box.png")
HUD.panelImageHUD = love.graphics.newImage("resources/images/hud/panel_map.png")

HUD.buttonBlueImageHUD = love.graphics.newImage("resources/images/hud/panel.png")
HUD.buttonBlueHoverImageHUD = love.graphics.newImage("resources/images/hud/panel_hover.png")
HUD.buttonBluePressedImageHUD = love.graphics.newImage("resources/images/hud/panel_pressed.png")

HUD.buttonRedImageHUD = love.graphics.newImage("resources/images/hud/panel2.png")
HUD.buttonRedHoverImageHUD = love.graphics.newImage("resources/images/hud/panel2_hover.png")
HUD.buttonRedPressedImageHUD = love.graphics.newImage("resources/images/hud/panel2_pressed.png")

HUD.mouseLeftImage = love.graphics.newImage("resources/images/hud/clickLeft.png")
HUD.mouseRightImage = love.graphics.newImage("resources/images/hud/clickRight.png")
HUD.keyXImage = love.graphics.newImage("resources/images/hud/key_x.png")
HUD.keyESCImage = love.graphics.newImage("resources/images/hud/key_esc.png")

HUD.color1 = {30, 150, 70}
HUD.color2 = {150, 30, 70}
HUD.color3 = {112, 128, 144}
HUD.color4 = {64, 64, 64}
HUD.colorPlay = {30, 70, 150}
HUD.colorExit = {170, 70, 30}

-- HUD
local panelFieldHUD = nil
local panelHeroHUD = nil
local textHeroFieldHUD = {}
local textHeroNameHUD = nil
local textHeroHPHUD = nil
local textHeroStrHUD = nil
local textHeroMvtHUD = nil
local textTurnHUD = nil
local buttonTurnHUD = nil
local groupFieldHUD
local groupHeroHUD
local groupMapHUD
local groupTurnHUD


function Hud.Load()
  panelFieldHUD = myGUI.newPanel(largeur_ecran - HUD.boxImageHUD:getWidth(), hauteur_ecran - HUD.boxImageHUD:getHeight())
  panelFieldHUD:setImage(HUD.boxImageHUD)
  
  panelHeroHUD = myGUI.newPanel(0, hauteur_ecran - HUD.panelImageHUD:getHeight()) 
  panelHeroHUD:setImage(HUD.panelImageHUD)
  
  textHeroNameHUD = myGUI.newText(panelHeroHUD.X+23, panelHeroHUD.Y + 28, 0, 0, "", Fonts.mainFont, "", "center", HUD.color4)
  textHeroHPHUD = myGUI.newText(panelHeroHUD.X+23, panelHeroHUD.Y + 53, 0, 0, "", Fonts.smallFont, "", "center", HUD.color3)
  textHeroStrHUD = myGUI.newText(panelHeroHUD.X+148, panelHeroHUD.Y + 53, 0, 0, "", Fonts.smallFont, "", "center", HUD.color3)
  textHeroMvtHUD = myGUI.newText(panelHeroHUD.X+268, panelHeroHUD.Y + 53, 0, 0, "", Fonts.smallFont, "", "center", HUD.color3)
  
  textHeroFieldHUD["PLAIN"] = myGUI.newText(panelHeroHUD.X+23, panelHeroHUD.Y + 80, 0, 0, "Plain", Fonts.smallFont, "", "center", HUD.color3)
  textHeroFieldHUD["FOREST"] = myGUI.newText(panelHeroHUD.X+148, panelHeroHUD.Y + 80, 0, 0, "Forest", Fonts.smallFont, "", "center", HUD.color3)
  textHeroFieldHUD["MOUNTAIN"] = myGUI.newText(panelHeroHUD.X+268, panelHeroHUD.Y + 80, 0, 0, "Mountain", Fonts.smallFont, "", "center",HUD.color3)
  
  textTurnHUD = myGUI.newText(largeur_ecran/2 - Fonts.bigFont:getWidth("Your Turn")/2, 20, 0, 0, "", Fonts.bigFont, "center", "center")
  buttonTurnHUD = myGUI.newButton((largeur_ecran - HUD.buttonBlueImageHUD:getWidth())/2 , 35,
                                HUD.buttonBlueImageHUD:getWidth(), HUD.buttonBlueImageHUD:getHeight(),"End Turn", Fonts.mainFont, HUD.color4)
  buttonTurnHUD:setImages(HUD.buttonBlueImageHUD, HUD.buttonBlueHoverImageHUD, HUD.buttonBluePressedImageHUD)
  buttonTurnHUD:setEvent("pressed", Game.OnChangeTurnPressedHUD)
  
  groupFieldHUD = myGUI.newGroup()
  groupHeroHUD = myGUI.newGroup()
  groupMapHUD = myGUI.newGroup()
  groupTurnHUD = myGUI.newGroup()
  
  groupTurnHUD:addElement(buttonTurnHUD)
  groupMapHUD:addElement(textTurnHUD)
  groupFieldHUD:addElement(panelFieldHUD)
  groupHeroHUD:addElement(panelHeroHUD)
  groupHeroHUD:addElement(textHeroNameHUD)
  groupHeroHUD:addElement(textHeroHPHUD)
  groupHeroHUD:addElement(textHeroStrHUD)
  groupHeroHUD:addElement(textHeroMvtHUD)
  
  for key, value in pairs(textHeroFieldHUD) do
    groupHeroHUD:addElement(value)
  end
  
  clickSound = love.audio.newSource("resources/sons/switch.ogg", "static")
  clickSound:setVolume(0.3)
end


function Hud.OnChangeTurnPressedHUD(pState)
  if pState == "end" then
    clickSound:play()
    Game.ChangeTurn()
  end
end

return HUD