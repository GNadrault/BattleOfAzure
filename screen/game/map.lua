local Map = {}

local Heros = require("entities/heros")
local Demons = require("entities/demons")
local Utils = require("utils/utils")
local Grid = require("utils/grid")

-- TileSheet, Textures
local tileSheet = {}
local tileTextures = {}
local current_state = nil
local current_turn = nil

-- Curseur
local selector = {}
local timer = 0

-- Hero/Demon courant
local hero = nil
local demon = nil
local moveGrid = {}
local movePath = {}

-- Bateau
local bateau = {}
bateau.images = {}
bateau.currentImage = 1
bateau.col = 4
bateau.line = 16

local field = {}
field.images = {}
field.index = 1
field.xoffset = 10
field.yoffset = 8

function Map.Load()
  
  -- Chargement des sprites de map depuis la TileSheet
  tileSheet = love.graphics.newImage("resources/images/tilesheet/tilesheet.png")
  local nbColumn = tileSheet:getWidth() / Map.TILE_WIDTH
  local nbLine = tileSheet:getHeight() / Map.TILE_HEIGHT
  local l,c
  local id = 1
  tileTextures[0] = nil
  for l=1,nbLine do
    for c=1,nbColumn do
      tileTextures[id] = love.graphics.newQuad(
        (c-1) * Map.TILE_WIDTH,
        (l-1) * Map.TILE_HEIGHT,
        Map.TILE_WIDTH,
        Map.TILE_HEIGHT,
        tileSheet:getWidth(),
        tileSheet:getHeight())
      id = id + 1
    end
  end
  
  selector.image = love.graphics.newImage("resources/images/divers/crosshair.png")
  
  -- Chargement bâteau
  bateau.images[1] = love.graphics.newImage("resources/images/divers/bateau1.png")
  bateau.images[2] = love.graphics.newImage("resources/images/divers/bateau2.png")
  field.images[1] = love.graphics.newImage("resources/images/divers/plain81.png")
  field.images[2] = love.graphics.newImage("resources/images/divers/forest81.png")
  field.images[3] = love.graphics.newImage("resources/images/divers/mountain81.png")
  
  Heros.Load()
  Demons.Load()
  
  -- Chargement des heros
  Heros.CreeHero("KNIGHT", 13, 13)
  Heros.CreeHero("KNIGHT", 16, 9)
  Heros.CreeHero("ARCHER", 8, 13)
  Heros.CreeHero("ARCHER", 6, 9)
  Heros.CreeHero("WIZARD", 10, 7)
  
  -- Chargement des demons
  Demons.CreeDemon("DEVIL", 12, 25)
  Demons.CreeDemon("GOBLIN", 8, 22)
  Demons.CreeDemon("GOBLIN", 19, 22)
  Demons.CreeDemon("TROLL", 13, 19)
  Demons.CreeDemon("TROLL", 18, 25)
end


function Map.Draw()
  local l,c
  for l=1,Grid.MAP_HEIGHT do
    for c=1,Grid.MAP_WIDTH do
      local idBack = Grid.Background[l][c]
      local idFront = Grid.Foreground[l][c]
      local spriteTextureBack = tileTextures[idBack]
      local spriteTextureFront = tileTextures[idFront]
      if spriteTextureBack ~= nil then
        love.graphics.draw(tileSheet, spriteTextureBack, (c-1) * Grid.TILE_WIDTH, (l-1) * Grid.TILE_HEIGHT)
      end
      if spriteTextureFront ~= nil then
        love.graphics.draw(tileSheet, spriteTextureFront, (c-1) * Grid.TILE_WIDTH, (l-1) * Grid.TILE_HEIGHT)
      end
    end
  end
  love.graphics.setColor(1,1,1)
  Game.DrawCursor()
  Game.DrawHeros()
  Game.DrawDemons()
  Game.DrawBoat()
  if current_state == "move" or current_state == "action" and not Utils.isEmptyTable(moveGrid) then
    Map.DrawGrid()
  end
  love.graphics.scale(0.5,0.5)
  if current_turn == "hero" then
    if hero ~= nil then
      groupHeroHUD:draw()
    end
    groupTurnHUD:draw()
  end
  groupMapHUD:draw()
  Map.DrawField()
  Map.DrawInstructions()
end


function Map.DrawField()
  if current_turn == "hero" and hero ~= nil then
    groupFieldHUD:draw()
    love.graphics.draw(field.images[field.index], panelFieldHUD.X + field.xoffset, panelFieldHUD.Y + field.yoffset)
  end
end

-- Dessine le curseur à l'emplacement de la souris
function Map.DrawCursor()
  local mouseX = love.mouse.getX()/2
  local mouseY = love.mouse.getY()/2
  selector.col = math.floor(mouseX/Map.TILE_WIDTH)
  selector.line = math.floor(mouseY/Map.TILE_HEIGHT)
  if selector.col >= 0 and selector.col <= Map.MAP_WIDTH and selector.line >= 0 and selector.line <= Map.MAP_HEIGHT and not Map.isObstacle(selector.line+1, selector.col+1)  then
    love.graphics.draw(selector.image, selector.col * Map.TILE_WIDTH, 
                       selector.line * Map.TILE_HEIGHT)
  end
end

-- Dessine les heros
function Map.DrawHeros()
  for n=1,#Heros.list_heros do
    local currentHero = Heros.list_heros[n]
    if not currentHero.active and not currentHero.dead then
      love.graphics.setColor(0.7, 0.7, 0.7, 0.8)
    end
    love.graphics.draw(Heros.dbHeros[currentHero.type].Image[currentHero.currentAnim][math.floor(currentHero.currentImage)], 
      currentHero.col * Map.TILE_WIDTH, currentHero.line * Map.TILE_HEIGHT)
    love.graphics.setColor(1,1,1,1)
  end
end

-- Dessine les demons
function Map.DrawDemons()
  for n=1,#Demons.list_demons do
    local currentDemon = Demons.list_demons[n]
    if not currentDemon.active then
      love.graphics.setColor(0.7,0.7,0.7,0.8)
    end
    love.graphics.draw(Demons.dbDemons[currentDemon.type].Image[currentDemon.currentAnim][math.floor(currentDemon.currentImage)], 
      currentDemon.col * Map.TILE_WIDTH, currentDemon.line * Map.TILE_HEIGHT)
    love.graphics.setColor(1,1,1,1)
  end
end

function Map.DrawBoat()
  love.graphics.draw(bateau.images[math.floor(bateau.currentImage)], bateau.col * Map.TILE_WIDTH, bateau.line * Map.TILE_HEIGHT)
end

function Map.DrawInstructions()
  if current_turn == "hero" then
    if hero == nil then
      love.graphics.print("Select & move", 10, 10, 0, 0.5, 0.5)
      love.graphics.draw(HUD.mouseLeftImage, 30, 35)
      love.graphics.print("Select & attack", 10, 92, 0, 0.5, 0.5)
      love.graphics.draw(HUD.mouseRightImage, 30, 117)
    else
      love.graphics.print("Wait", 30, 10, 0, 0.5, 0.5)
      love.graphics.draw(HUD.keyXImage, 30, 35)
      love.graphics.print("Cancel", 25, 78, 0, 0.5, 0.5)
      love.graphics.draw(HUD.keyESCImage, 30, 103)
    end
  end
end

-- Dessine la grille
function Map.DrawGrid()
  for index, valeur in ipairs(moveGrid) do
    if current_state == "move" or current_state == "moving" then
      love.graphics.setColor(0.17, 0.56, 0.78, 0.6)
    elseif current_state == "action" then
      love.graphics.setColor(0.8, 0.2, 0.2, 0.6)
    end
    love.graphics.rectangle("fill", valeur.col * Map.TILE_WIDTH, 
                valeur.line * Map.TILE_HEIGHT, Map.TILE_WIDTH, Map.TILE_HEIGHT)
    love.graphics.setColor(1, 1, 1)
    if selector.line == valeur.line and selector.col == valeur.col then
      love.graphics.print(valeur.g, valeur.col * Map.TILE_WIDTH + Map.TILE_WIDTH/3, valeur.line * Map.TILE_HEIGHT, 0, 0.35, 0.35)
    end
  end
end



function Map.Update(dt)
  
  
end


return Map