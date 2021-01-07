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

return HUD