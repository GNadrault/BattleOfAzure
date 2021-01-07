local Game = {}

local Map = require("map/map")
local Heros = require("entities/heros")
local Demons = require("entities/demons")
local Battle = require("battle/battle")
local Finish = require("screen/finish")
local Menu = require("screen/menu")
local Node = require("grid/node")
local Path = require("grid/path")
local myGUI = require("utils/GUI")
local HUD = require("screen/hud")
local Utils = require("utils/utils")

-- Contexte
Turn = nil
Etat = nil
Screen = nil

-- TileSheet, Textures
local tileSheet = {}
local tileTextures = {}

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

-- Music, Son
local music = nil
local clickSound = nil

function Game.OnChangeTurnPressedHUD(pState)
  if pState == "end" then
    clickSound:play()
    Game.ChangeTurn()
  end
end

------- LOAD -------
--------------------

function Game.Load()
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
  
  Menu.Load()
  Heros.Load()
  Demons.Load()
  Map.Load()
  Battle.Load()
  Finish.Load()

  selector.image = love.graphics.newImage("resources/images/divers/crosshair.png")
  
  -- Chargement bâteau
  bateau.images[1] = love.graphics.newImage("resources/images/divers/bateau1.png")
  bateau.images[2] = love.graphics.newImage("resources/images/divers/bateau2.png")
  field.images[1] = love.graphics.newImage("resources/images/divers/plain81.png")
  field.images[2] = love.graphics.newImage("resources/images/divers/forest81.png")
  field.images[3] = love.graphics.newImage("resources/images/divers/mountain81.png")

  -- HUD
  panelFieldHUD = myGUI.newPanel(largeur_ecran - HUD.boxImageHUD:getWidth(), hauteur_ecran - HUD.boxImageHUD:getHeight())
  panelFieldHUD:setImage(HUD.boxImageHUD)
  
  panelHeroHUD = myGUI.newPanel(0, hauteur_ecran - HUD.panelImageHUD:getHeight()) 
  panelHeroHUD:setImage(HUD.panelImageHUD)
  
  textHeroNameHUD = myGUI.newText(panelHeroHUD.X+23, panelHeroHUD.Y + 28, 0, 0, "", mainFont, "", "center", HUD.color4)
  textHeroHPHUD = myGUI.newText(panelHeroHUD.X+23, panelHeroHUD.Y + 53, 0, 0, "", smallFont, "", "center", HUD.color3)
  textHeroStrHUD = myGUI.newText(panelHeroHUD.X+148, panelHeroHUD.Y + 53, 0, 0, "", smallFont, "", "center", HUD.color3)
  textHeroMvtHUD = myGUI.newText(panelHeroHUD.X+268, panelHeroHUD.Y + 53, 0, 0, "", smallFont, "", "center", HUD.color3)
  
  textHeroFieldHUD["PLAIN"] = myGUI.newText(panelHeroHUD.X+23, panelHeroHUD.Y + 80, 0, 0, "Plain", smallFont, "", "center", HUD.color3)
  textHeroFieldHUD["FOREST"] = myGUI.newText(panelHeroHUD.X+148, panelHeroHUD.Y + 80, 0, 0, "Forest", smallFont, "", "center", HUD.color3)
  textHeroFieldHUD["MOUNTAIN"] = myGUI.newText(panelHeroHUD.X+268, panelHeroHUD.Y + 80, 0, 0, "Mountain", smallFont, "", "center",HUD.color3)
  
  textTurnHUD = myGUI.newText(largeur_ecran/2 - bigFont:getWidth("Your Turn")/2, 20, 0, 0, "", bigFont, "center", "center")
  buttonTurnHUD = myGUI.newButton((largeur_ecran - HUD.buttonBlueImageHUD:getWidth())/2 , 35,
                                HUD.buttonBlueImageHUD:getWidth(), HUD.buttonBlueImageHUD:getHeight(),"End Turn", mainFont, HUD.color4)
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

  music = love.audio.newSource("resources/sons/Woodland Fantasy.mp3", "static")
  music:setVolume(0.5)
  music:setLooping(true)
  
  clickSound = love.audio.newSource("resources/sons/switch.ogg", "static")
  clickSound:setVolume(0.3)

  Turn = "HERO"
  Screen = "MENU"
  Etat = "SELECTION"
  Menu.Start()
end

function Game.Start()
  Finish.restart = false
  Finish.backToMenu = false
  Heros.list_heros = {}
  Demons.list_demons = {}
  Map.Load()
  hero = nil
  demon = nil
  moveGrid = {}
  movePath = {}
  Turn = "HERO"
  Screen = "MAP"
  Etat = "SELECTION"
  Menu.music:stop()
  music:play()
end


------- DRAW -------
--------------------

function Game.Draw()
  if Screen == "MENU" then
    Game.DrawMenu()
  elseif Screen == "MAP" or Screen == "BATTLE" or Screen == "VICTORY" or Screen == "GAMEOVER" then
    Game.DrawGame()
  end
end

-- Dessine le menu du jeu
function Game.DrawMenu()
  Menu.Draw()
end

-- Dessine le jeu
function Game.DrawGame()
  love.graphics.scale(2,2)
  Game.DrawMap(Map)
  if Screen == "MAP" then
    Game.DrawCursor()
    Game.DrawHeros()
    Game.DrawDemons()
    Game.DrawBoat()
    if Etat == "MOVE" or Etat == "ACTION" and not Utils.isEmptyTable(moveGrid) then
      Game.DrawGrid()
    end
    love.graphics.scale(0.5,0.5)
    if Turn == "HERO" then
      if hero ~= nil then
        groupHeroHUD:draw()
      end
      groupTurnHUD:draw()
    end
    groupMapHUD:draw()
    Game.DrawField()
    Game.DrawInstructions()
  elseif Screen == "BATTLE" then
    love.graphics.scale(0.5,0.5)
    Battle.Draw()
  elseif Screen == "VICTORY" or Screen == "GAMEOVER" then
    love.graphics.scale(0.5,0.5)
    Finish.Draw()
  end
end

function Game.DrawField()
  if Turn == "HERO" and hero ~= nil then
    groupFieldHUD:draw()
    love.graphics.draw(field.images[field.index], panelFieldHUD.X + field.xoffset, panelFieldHUD.Y + field.yoffset)
  end
end

-- Dessine le curseur à l'emplacement de la souris
function Game.DrawCursor()
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
function Game.DrawHeros()
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
function Game.DrawDemons()
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

function Game.DrawBoat()
  love.graphics.draw(bateau.images[math.floor(bateau.currentImage)], bateau.col * Map.TILE_WIDTH, bateau.line * Map.TILE_HEIGHT)
end

-- Dessine la map
function Game.DrawMap(map)
  if Screen == "BATTLE" or Screen == "VICTORY" or Screen == "GAMEOVER" then
    love.graphics.setColor(0.2,0.2,0.2, 0.5)
  end
  local l,c
  for l=1,map.MAP_HEIGHT do
    for c=1,map.MAP_WIDTH do
      local idBack = map.Background[l][c]
      local idFront = map.Foreground[l][c]
      local spriteTextureBack = tileTextures[idBack]
      local spriteTextureFront = tileTextures[idFront]
      if spriteTextureBack ~= nil then
        love.graphics.draw(tileSheet, spriteTextureBack, (c-1) * map.TILE_WIDTH, (l-1) * map.TILE_HEIGHT)
      end
      if spriteTextureFront ~= nil then
        love.graphics.draw(tileSheet, spriteTextureFront, (c-1) * map.TILE_WIDTH, (l-1) * map.TILE_HEIGHT)
      end
    end
  end
  love.graphics.setColor(1,1,1)
end

function Game.DrawInstructions()
  if Turn == "HERO" then
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
function Game.DrawGrid()
  for index, valeur in ipairs(moveGrid) do
    if Etat == "MOVE" or Etat == "MOVING" then
      love.graphics.setColor(0.17, 0.56, 0.78, 0.6)
    elseif Etat == "ACTION" then
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

-- Créer la grille de déplacement/d'action du personnage
function Game.CreateGrid(pLine, pCol, move_distance)
  local starting_pos = Node:new(nil, pLine, pCol, 0, 0, 0)
  movePath = {}
  moveGrid = {}
  table.insert(moveGrid, starting_pos)
  local move = 1
  while move <= move_distance do
    local new_positions = {}
    for index, valeur in ipairs(moveGrid) do
      local up_pos = Node:new(nil, valeur.line-1, valeur.col, move, 0, 0)
      local right_pos = Node:new(nil, valeur.line, valeur.col+1, move, 0, 0)
      local down_pos = Node:new(nil, valeur.line+1, valeur.col, move, 0, 0)
      local left_pos = Node:new(nil, valeur.line, valeur.col-1, move, 0, 0)
      table.insert(new_positions, up_pos)
      table.insert(new_positions, right_pos)
      table.insert(new_positions, down_pos)
      table.insert(new_positions, left_pos)
    end
    for index, valeur in ipairs(new_positions) do
      if Utils.getPosInTable(valeur.line, valeur.col, moveGrid) == 0 then
        if valeur.col>0 and valeur.col<= Map.MAP_WIDTH and valeur.line>0 and valeur.line<= Map.MAP_HEIGHT then
          if not Map.isObstacle(valeur.line+1, valeur.col+1) then
            if Etat == "MOVE" then
              if Heros.getHeroAt(valeur.line,valeur.col) == nil and Demons.getDemonAt(valeur.line,valeur.col) == nil then
                table.insert(moveGrid, valeur)
              end
            elseif Etat == "ACTION" then
              if Turn == "HERO" then
                if Heros.getHeroAt(valeur.line,valeur.col) == nil then
                  table.insert(moveGrid, valeur)
                end
              elseif Turn == "DEMON" then
                if Demons.getDemonAt(valeur.line,valeur.col) == nil then
                  table.insert(moveGrid, valeur)
                end
              end
            end
          end
        end
      end
    end
    move = move + 1
  end
  -- On retire le déplacement de la case du personnage
  table.remove(moveGrid, 1)
end

-- Creer le path le plus court du point de départ au point d'arrive
function Game.CreatePath(startLine, startCol, endLine, endCol)
  local finalNode = Path.FindPath(startLine, startCol, endLine, endCol)
  movePath = {}
  if finalNode ~= nil then
    local currentNode = finalNode
    while currentNode ~= nil do
      local pos = Utils.getPosInTable(currentNode.line, currentNode.col, moveGrid)
      if pos > 0 then
        table.insert(movePath, currentNode)
      end
      currentNode = currentNode.parent
    end
  end
end

------ UPDATE ------
--------------------

-- Mise à jour de la map
function Game.UpdateMap(dt)
  
  if hero ~= nil then
    Game.UpdateInfosHeros(dt)
  end
  
  local currentField = Map.GetField(selector.line+1, selector.col+1)
  if currentField == "PLAIN" then
    field.index = 1
  elseif currentField == "FOREST" then
    field.index = 2
  else
    field.index = 3
  end
  
  -- Vérification hero mort et game over
  for index, hero in ipairs(Heros.list_heros) do
    if hero.dead then
      table.remove(Heros.list_heros, index)
      if Utils.isEmptyTable(Heros.list_heros) then
        Screen = "GAMEOVER"
      end
    end
  end
  
  -- Vérification demon mort et victoire
  for index, demon in ipairs(Demons.list_demons) do
    if demon.dead then
      table.remove(Demons.list_demons, index)
      if Utils.isEmptyTable(Demons.list_demons) then
        Screen = "VICTORY"
      end
    end
  end
  
  -- Animation du bâteau
  bateau.currentImage = bateau.currentImage + 3 * dt
  if bateau.currentImage >= 3 then
    bateau.currentImage = 1
  end

  -- Animations des heros
  for index, hero in ipairs(Heros.list_heros) do
    hero.currentImage = hero.currentImage + Heros.frameSpeed * dt
    if hero.currentImage >= 5 then
      hero.currentImage = 1
    end
  end
  
  -- Animations des demons
  for index, demon in ipairs(Demons.list_demons) do
    demon.currentImage = demon.currentImage + Demons.frameSpeed * dt
    if demon.currentImage >= 5 then
      demon.currentImage = 1
    end
  end
  
  if Turn == "HERO" then
    textTurnHUD:setText("Your Turn")
    local allInactif = true
    for index, hero in ipairs(Heros.list_heros) do
      allInactif = allInactif and not hero.active
    end
    if allInactif then
      Game.ChangeTurn()
    else
      if Etat == "MOVING" then
        Game.UpdateMoving(hero, dt)
      end
    end
  elseif Turn == "DEMON" then
    textTurnHUD:setText("Demon's Turn")
    local allInactif = true
    for index, demon in ipairs(Demons.list_demons) do
      allInactif = allInactif and not demon.active
    end
    if allInactif then
      Game.ChangeTurn()
    else
      if Etat == "SELECTION" then
        Game.SelectDemon()
      -- Gestion des déplacement vers case finale
      elseif Etat == "MOVING" then
        Game.UpdateMoving(demon, dt)
      else
        timer = timer + 5 * dt
        if timer >= 10 then
          timer = 0
          if Etat == "MOVE" then
            if not Game.AttackIfHeroClose(demon, true, dt) then
              Game.CreateGrid(demon.line, demon.col, demon.PM)
              Game.CreateShortestPathToHero()
            end
          end
        end
      end
    end
  end
end

function Game.UpdateInfosHeros(dt)
  textHeroNameHUD:setText(hero.type)
  textHeroHPHUD:setText("HP : "..hero.HP)
  textHeroStrHUD:setText("Str : "..hero.force)
  textHeroMvtHUD:setText("Mvt : "..hero.PM)
  for key, value in pairs(Heros.dbHeros[hero.type].Effect) do
    textHeroFieldHUD[key]:setText(key.." x"..value.."")
    if value < 1 then
      textHeroFieldHUD[key]:setColor(HUD.color2)
    elseif value > 1 then
      textHeroFieldHUD[key]:setColor(HUD.color1)
    else
      textHeroFieldHUD[key]:setColor(HUD.color3)
    end
  end
end

function Game.UpdateMoving(actor, dt)
  actor.col = actor.col + dirX * speed * dt
  actor.line = actor.line + dirY * speed * dt
  local currentdist = math.dist(actor.col, actor.line, player_oldCol, player_oldLine)
  if currentdist >= distance then
    actor.col = player_newCol
    actor.line = player_newLine
    if player_index > 1 then
      player_index = player_index - 1
      Game.MoveTo(movePath[player_index].col, movePath[player_index].line, speed, actor)
    else
      local pos = Utils.getPosInTable(actor.line, actor.col, moveGrid)
      actor.PM = actor.PM - moveGrid[pos].g 
      actor.currentAnim = "Idle"
      if actor.PM <= 0 then
        actor.PM = 0
      end
      moveGrid = {}
      movePath = {}
      Etat = "MOVE"
    end
  end
end

function Game.AttackIfHeroClose(demon)
  -- Récupération du hero le plus proche du demon courant
  local closestHero = Heros.list_heros[1]
  local closestHeroDist = math.abs(demon.col - closestHero.col) + math.abs(demon.line - closestHero.line)
  for index, hero in ipairs(Heros.list_heros) do
    local dist = math.abs(demon.col - hero.col) + math.abs(demon.line - hero.line)
    if dist < closestHeroDist then
      closestHeroDist = dist
      closestHero = hero
    end
  end
  -- Si distance <= 1 du hero alors demon peut attaquer
  if closestHeroDist <= 1 then
    local typeFieldHero = Map.GetField(closestHero.line+1, closestHero.col+1)
    local typeFieldDemon = Map.GetField(demon.line+1, demon.col+1)
    Battle.Start(closestHero, demon, Turn, typeFieldHero, typeFieldDemon)
    demon.active = false
    demon = nil
    moveGrid = {}
    movePath = {}
    Screen = "BATTLE"
    Etat = "SELECTION"
    return true
  end
  return false
end

-- Mise à jour de la bataille
function Game.UpdateBattle(dt)
  Battle.Update(dt)
end

function Game.Update(dt)
  if Screen == "MENU" then
    Menu.Update(dt)
    if Menu.play == true then
      Game.Start()
    end
  elseif Screen == "MAP" then
    if not music:isPlaying() then 
      music:play()
    end
    if Turn == "HERO" then
      groupTurnHUD:update()
    end
    Game.UpdateMap(dt)
    groupMapHUD:update(dt)
    groupFieldHUD:update(dt)
    groupHeroHUD:update(dt)
  elseif Screen == "BATTLE" then
    if not Battle.play then
      Screen = "MAP"
      Etat = "SELECTION"
      hero = nil
      demon = nil
      moveGrid = {}
      movePath = {}
    else
      Game.UpdateBattle(dt)
    end
    if music:isPlaying() then 
      love.audio.pause(music)
    end
  elseif Screen == "VICTORY" or Screen == "GAMEOVER" then
    if music:isPlaying() then 
      music:stop()
    end
    if Finish.restart then
      Game.Start()
    elseif Finish.backToMenu then
      Screen = "MENU"
      Menu.Start()
    end
    if Screen == "VICTORY" then
      Finish.Update(dt, true)
    else
      Finish.Update(dt, false)
    end
  end
end

-- Calcul du déplacement vers une case
function Game.MoveTo(pCol, pLine, pSpeed, actor)
  player_oldCol = actor.col
  player_oldLine = actor.line
  player_newCol = pCol
  player_newLine = pLine
  
  dX = player_newCol - player_oldCol
  dY = player_newLine - player_oldLine
  
  distance = math.sqrt(dX^2 + dY^2)
  dirX = dX / distance
  dirY = dY / distance

  speed = pSpeed
end

-- Change le tour
function Game.ChangeTurn()
  if Turn == "HERO" then
    Demons.ResetPoints()
    Turn = "DEMON"
    hero = nil
  else
    Heros.ResetPoints()
    Turn = "HERO"
  end
  Etat = "SELECTION"
end

-- Selectionne un demon aléatoire
function Game.SelectDemon()
  local tableDemon = {}
  for index, demon in ipairs(Demons.list_demons) do
    if not demon.dead and demon.active then
      table.insert(tableDemon, demon)
    end
  end
  if not Utils.isEmptyTable(tableDemon) then
    local rndChoice = math.random(1,#tableDemon)
    demon = tableDemon[rndChoice]
    Etat = "MOVE"
  else
    Game.ChangeTurn()
  end
end

function Game.GetClosestPathAround(pLineE, pColE, pLineS, pColS)
  local nodes = {}
  local finalNodeUp = Path.FindPath(pLineE, pColE, pLineS-1, pColS)
  if finalNodeUp ~= nil then
    table.insert(nodes, finalNodeUp)
  end
  local finalNodeRight = Path.FindPath(pLineE, pColE, pLineS, pColS+1)
  if finalNodeRight ~= nil then
    table.insert(nodes, finalNodeRight)
  end
  local finalNodeDown = Path.FindPath(pLineE, pColE, pLineS+1, pColS)
  if finalNodeDown ~= nil then
    table.insert(nodes, finalNodeDown)
  end
  local finalNodeLeft = Path.FindPath(pLineE, pColE, pLineS, pColS-1)
  if finalNodeLeft ~= nil then
    table.insert(nodes, finalNodeLeft)
  end
  local shortestPathHero = nodes[1]
  for index, node in ipairs(nodes) do
    if node.f < shortestPathHero.f then
      shortestPathHero = node
    end
  end
  return shortestPathHero
end

function Game.CreateShortestPathToHero()
  local shortPaths = {}
  for index, hero in ipairs(Heros.list_heros) do
    local closestPathToHero = Game.GetClosestPathAround(demon.line, demon.col, hero.line, hero.col)
    if closestPathToHero ~= nil then
      table.insert(shortPaths, closestPathToHero)
    end
  end
  local closestPath = nil
  if not Utils.isEmptyTable(shortPaths) then
    closestPath = shortPaths[1]
    for index, path in ipairs(shortPaths) do
      if path.f < closestPath.f then
        closestPath = path
      end
    end
  end
  movePath = {}
  if closestPath ~= nil then
    local currentNode = closestPath
    while currentNode ~= nil do
      local pos = Utils.getPosInTable(currentNode.line, currentNode.col, moveGrid)
      if pos > 0 then
        table.insert(movePath, currentNode)
      end
      currentNode = currentNode.parent
    end
    if not Utils.isEmptyTable(movePath) then
      player_index = #movePath
      Game.MoveTo(movePath[player_index].col, movePath[player_index].line, Demons.moveSpeed, demon)
      demon.currentAnim = "Walk"
      Etat = "MOVING"
    else
      demon.active = false
      Etat = "SELECTION"
    end
  else
    demon.active = false
    Etat = "SELECTION"
  end
end

------- KEYS -------
--------------------

function Game.KeyPressed(key)
  if Screen == "MAP" then
    if Turn == "HERO" then
      if key == "escape" then
        if Etat == "MOVE" or Etat == "ACTION" then
          hero = nil
          moveGrid = {}
          movePath = {}
          Etat = "SELECTION"
        end
      elseif key == "x" then
        if hero ~= nil then
          print("Hero attend !!")
          hero.active = false
          hero = nil
          moveGrid = {}
          movePath = {}
          Etat = "SELECTION"
        end
      end
    end
  end
end

function Game.MousePressed(button)
  if Turn == "HERO" then
    if button == 1 then
      -- MAP => Sélection du hero pour déplacement
      if Etat == "SELECTION" then
        local heroAt = Heros.getHeroAt(selector.line, selector.col)
        if heroAt ~= nil and heroAt.active and not heroAt.dead then
          hero = heroAt
          Etat = "MOVE"
          Game.CreateGrid(hero.line, hero.col, hero.PM)
        end
      -- MOVE => Déplacement du hero dans la grille
      elseif Etat == "MOVE" then
        local heroAt = Heros.getHeroAt(selector.line, selector.col)
        if heroAt ~= nil and heroAt.active and not heroAt.dead then
          hero = heroAt
          Game.CreateGrid(hero.line, hero.col, hero.PM)
        else
          local pos = Utils.getPosInTable(selector.line, selector.col, moveGrid)
          if pos > 0 then
            Game.CreatePath(hero.line, hero.col, selector.line, selector.col)
            player_index = #movePath
            Game.MoveTo(movePath[player_index].col, movePath[player_index].line, Heros.moveSpeed, hero)
            hero.currentAnim = "Walk"
            Etat = "MOVING"
          end
        end
      -- ACTION => Battle du hero vers ennemi
      elseif Etat == "ACTION" then
        local heroAt = Heros.getHeroAt(selector.line, selector.col)
        if heroAt ~= nil and heroAt.active and not heroAt.dead then
          hero = heroAt
          Etat = "MOVE"
          Game.CreateGrid(hero.line, hero.col, hero.PM)
        else
          local pos = Utils.getPosInTable(selector.line, selector.col, moveGrid)
          if pos > 0 then
            local demon = Demons.getDemonAt(selector.line, selector.col)
            if demon ~= nil then
              local typeFieldHero = Map.GetField(hero.line+1, hero.col+1)
              local typeFieldDemon = Map.GetField(demon.line+1, demon.col+1)
              Battle.Start(hero, demon, Turn, typeFieldHero, typeFieldDemon)
              moveGrid = {}
              movePath = {}
              Etat = "SELECTION"
              Screen = "BATTLE"
              hero.active = false
            end
          end
        end
      end
    elseif button == 2 then
      -- Sélection du hero pour attaquer
      if Etat == "SELECTION" or Etat == "MOVE" or Etat == "ACTION" then
        local heroAt = Heros.getHeroAt(selector.line, selector.col)
        if heroAt ~= nil and heroAt.active and not heroAt.dead then
          hero = heroAt
          Etat = "ACTION"
          Game.CreateGrid(hero.line, hero.col, hero.PA)
        end
      end
    end
  end
end

return Game