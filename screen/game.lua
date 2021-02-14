local Game = {}

local Grid = require("utils/grid")
local Heros = require("entities/heros")
local Demons = require("entities/demons")
local Battle = require("screen/battle")
local Finish = require("screen/finish")
local Node = require("grid/node")
local Path = require("grid/path")
local myGUI = require("utils/GUI")
local HUD = require("utils/hud")
local Utils = require("utils/utils")
local Fonts = require("utils/fonts")

-- Contexte
local current_game = nil


-- Music, Son
local music = nil
local clickSound = nil



------- LOAD -------
--------------------

function Game.Load()

  




  music = love.audio.newSource("resources/sons/Woodland Fantasy.mp3", "static")
  music:setVolume(0.5)
  music:setLooping(true)

  current_turn = "hero"
  current_game = "map"
  current_state = "selection"
end

function Game.Start()
  Heros.list_heros = {}
  Demons.list_demons = {}
  Map.Load()
  hero = nil
  demon = nil
  current_turn = "hero"
  current_game = "map"
  current_state = "selection"
  music:play()
end


------- DRAW -------
--------------------

-- Dessine le jeu
function Game.Draw()
  elseif current_game == "battle" then
    love.graphics.scale(0.5,0.5)
    Battle.Draw()
  elseif current_game == "finish" then
    love.graphics.scale(0.5,0.5)
    Finish.Draw()
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
        current_game = "finish"
      end
    end
  end
  
  -- Vérification demon mort et victoire
  for index, demon in ipairs(Demons.list_demons) do
    if demon.dead then
      table.remove(Demons.list_demons, index)
      if Utils.isEmptyTable(Demons.list_demons) then
        current_game = "finish"
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
  
  if current_turn == "hero" then
    textTurnHUD:setText("Your Turn")
    local allInactif = true
    for index, hero in ipairs(Heros.list_heros) do
      allInactif = allInactif and not hero.active
    end
    if allInactif then
      Game.ChangeTurn()
    else
      if current_state == "moving" then
        Game.UpdateMoving(hero, dt)
      end
    end
  elseif current_turn == "demon" then
    textTurnHUD:setText("Demon's Turn")
    local allInactif = true
    for index, demon in ipairs(Demons.list_demons) do
      allInactif = allInactif and not demon.active
    end
    if allInactif then
      Game.ChangeTurn()
    else
      if current_state == "selection" then
        Game.SelectDemon()
      -- Gestion des déplacement vers case finale
      elseif current_state == "moving" then
        Game.UpdateMoving(demon, dt)
      else
        timer = timer + 5 * dt
        if timer >= 10 then
          timer = 0
          if current_state == "move" then
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
      current_state = "move"
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
    Battle.Start(closestHero, demon, current_turn, typeFieldHero, typeFieldDemon)
    demon.active = false
    demon = nil
    moveGrid = {}
    movePath = {}
    current_game = "battle"
    current_state = "selection"
    return true
  end
  return false
end

-- Mise à jour de la bataille
function Game.UpdateBattle(dt)
  Battle.Update(dt)
end

function Game.Update(dt)
  Game.Start()
  if current_game == "map" then
    if not music:isPlaying() then 
      music:play()
    end
    if current_turn == "hero" then
      groupTurnHUD:update()
    end
    Game.UpdateMap(dt)
    groupMapHUD:update(dt)
    groupFieldHUD:update(dt)
    groupHeroHUD:update(dt)
  elseif current_game == "battle" then
    if not Battle.play then
      current_game = "map"
      current_state = "selection"
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
  elseif current_game == "finish" then
    if music:isPlaying() then 
      music:stop()
    end
    if Finish.restart then
      Game.Start()
    elseif Finish.backToMenu then
      switchScene("menu")
    end
    Finish.Update(dt, false)
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
  if current_turn == "hero" then
    Demons.ResetPoints()
    current_turn = "demon"
    hero = nil
  else
    Heros.ResetPoints()
    current_turn = "hero"
  end
  current_state = "selection"
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
    current_state = "move"
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
      current_state = "moving"
    else
      demon.active = false
      current_state = "selection"
    end
  else
    demon.active = false
    current_state = "selection"
  end
end

------- KEYS -------
--------------------

function Game.KeyPressed(key)
  if current_game == "map" then
    if current_turn == "hero" then
      if key == "escape" then
        if current_state == "move" or current_state == "action" then
          hero = nil
          moveGrid = {}
          movePath = {}
          current_state = "selection"
        end
      elseif key == "x" then
        if hero ~= nil then
          hero.active = false
          hero = nil
          moveGrid = {}
          movePath = {}
          current_state = "selection"
        end
      end
    end
  end
end

function Game.MousePressed(button)
  if current_turn == "hero" then
    if button == 1 then
      -- MAP => Sélection du hero pour déplacement
      if current_state == "selection" then
        local heroAt = Heros.getHeroAt(selector.line, selector.col)
        if heroAt ~= nil and heroAt.active and not heroAt.dead then
          hero = heroAt
          current_state = "move"
          Game.CreateGrid(hero.line, hero.col, hero.PM)
        end
      -- MOVE => Déplacement du hero dans la grille
      elseif current_state == "move" then
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
            current_state = "moving"
          end
        end
      -- ACTION => Battle du hero vers ennemi
      elseif current_state == "action" then
        local heroAt = Heros.getHeroAt(selector.line, selector.col)
        if heroAt ~= nil and heroAt.active and not heroAt.dead then
          hero = heroAt
          current_state = "move"
          Game.CreateGrid(hero.line, hero.col, hero.PM)
        else
          local pos = Utils.getPosInTable(selector.line, selector.col, moveGrid)
          if pos > 0 then
            local demon = Demons.getDemonAt(selector.line, selector.col)
            if demon ~= nil then
              local typeFieldHero = Map.GetField(hero.line+1, hero.col+1)
              local typeFieldDemon = Map.GetField(demon.line+1, demon.col+1)
              Battle.Start(hero, demon, current_turn, typeFieldHero, typeFieldDemon)
              moveGrid = {}
              movePath = {}
              current_state = "selection"
              current_game = "battle"
              hero.active = false
            end
          end
        end
      end
    elseif button == 2 then
      -- Sélection du hero pour attaquer
      if current_state == "selection" or current_state == "move" or current_state == "action" then
        local heroAt = Heros.getHeroAt(selector.line, selector.col)
        if heroAt ~= nil and heroAt.active and not heroAt.dead then
          hero = heroAt
          current_state = "action"
          Game.CreateGrid(hero.line, hero.col, hero.PA)
        end
      end
    end
  end
end

return Game