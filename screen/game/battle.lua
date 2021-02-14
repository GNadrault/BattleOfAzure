local Battle = {}

local Heros = require("entities/heros")
local Demons = require("entities/demons")
local Utils = require("utils/utils")
local myGUI = require("utils/GUI")

math.randomseed(love.timer.getTime())

-- Background
local fields = {"PLAIN","FOREST","MOUNTAIN"}
local fieldHero = nil
local fieldDemon = nil
local background = {}
local frontLeft = {}
local frontRight = {}

-- TileSheet
local tileSheet = {}
local nbTileCol = 10
local nbTileLine = 6
local positions = {}
positions[1] = {x=240; y=430}
positions[2] = {x=200; y=550}
positions[3] = {x=260; y=650}

-- Units
local unitsFixed = false
local bonusHeroField = 1
local list_heros = {}
local list_demons = {}
local animations = {}
local hero = nil
local demon = nil
local turn = ""

-- Tour, timer
local timer = 0
local timerSpeed = 20
local count = 0
local loseHP = 0
local hpSpeed = 80
local backToMAP = false

-- HP
local barHeroHUD = nil
local barDemonHUD = nil
local groupHPHUD

-- Shaking
local t = 0
local shakeDuration = -1
local shakeMagnitude = 0
local isShaking = false

-- Music
local music = nil
local hit = nil

function Battle.StartShake(duration, magnitude)
  t = 0
  shakeDuration = duration or 1 
  shakeMagnitude = magnitude or 5
  isShaking = true
end

function Battle.CreateSprite(pType, pPosXInit, pPosXFinal, pPosYFinal, pFirstAnim)
  local sprite = {}
  sprite.type = pType
  sprite.tileSheet = tileSheet[pType].img
  sprite.tileSprite = tileSheet[pType].sprite
  sprite.finalX = pPosXFinal
  sprite.finalY = pPosYFinal
  sprite.x = pPosXInit
  sprite.y = pPosYFinal
  sprite.moveSpeed = 500
  sprite.animSpeed = 15
  sprite.currentImage = animations[pFirstAnim].frame
  sprite.currentAnim = pFirstAnim
  sprite.nextAnim = pFirstAnim
  return sprite
end


function Battle.Init()
  unitsFixed = false
  list_heros = {}
  list_demons = {}
  hero = nil
  demon = nil
  loseHP = 0
  count = 0
end

function Battle.Load()

  -- Animation des unites
  animations["ATTACK"] = {}
  animations["ATTACK"].frame = 1
  animations["ATTACK"].loop = false
  animations["DIE"] = {}
  animations["DIE"].frame = 11
  animations["DIE"].loop = false
  animations["HIT"] = {}
  animations["HIT"].frame = 21
  animations["HIT"].loop = false
  animations["IDLE"] = {}
  animations["IDLE"].frame = 31
  animations["IDLE"].loop = true
  animations["JUMP"] = {}
  animations["JUMP"].frame = 41
  animations["JUMP"].loop = false
  animations["RUN"] = {}
  animations["RUN"].frame = 51
  animations["RUN"].loop = true
  
    -- Chargement des unites
  Battle.LoadUnits(Heros.typeHero)
  Battle.LoadUnits(Demons.typeDemon)
  
  -- Plaine
  background["PLAIN"] = {} 
  background["PLAIN"].back = {}
  background["PLAIN"].back[1] = love.graphics.newImage("resources/images/battle/background/battleback10-2_left.png") 
  background["PLAIN"].back[2] = love.graphics.newImage("resources/images/battle/background/battleback10-2_right.png") 
  background["PLAIN"].front = {}
  background["PLAIN"].front[1] =  love.graphics.newImage("resources/images/battle/background/battleback10-1_left.png")
  background["PLAIN"].front[2] =  love.graphics.newImage("resources/images/battle/background/battleback10-1_right.png")
  -- Forêt
  background["FOREST"] = {}
  background["FOREST"].back = {}
  background["FOREST"].back[1] = love.graphics.newImage("resources/images/battle/background/battleback1-2_left.png") 
  background["FOREST"].back[2] = love.graphics.newImage("resources/images/battle/background/battleback1-2_right.png") 
  background["FOREST"].front =  {}
  background["FOREST"].front[1] =  love.graphics.newImage("resources/images/battle/background/battleback1-1_left.png")
  background["FOREST"].front[2] =  love.graphics.newImage("resources/images/battle/background/battleback1-1_right.png")
  -- Montagne
  background["MOUNTAIN"] = {}
  background["MOUNTAIN"].back = {}
  background["MOUNTAIN"].back[1] = love.graphics.newImage("resources/images/battle/background/battleback2-2_left.png") 
  background["MOUNTAIN"].back[2] = love.graphics.newImage("resources/images/battle/background/battleback2-2_right.png") 
  background["MOUNTAIN"].front =  {}
  background["MOUNTAIN"].front[1] =  love.graphics.newImage("resources/images/battle/background/battleback2-1_left.png")
  background["MOUNTAIN"].front[2] =  love.graphics.newImage("resources/images/battle/background/battleback2-1_right.png")
  
  local bar_emptyHUD = love.graphics.newImage("resources/images/battle/hud/bar_empty.png")
  local bar_fullHUD = love.graphics.newImage("resources/images/battle/hud/bar_full.png")
  
  barHeroHUD = myGUI.newProgressBar(50, 20, 405, 43, 100, {50,50,50}, {250, 129, 50})
  barDemonHUD = myGUI.newProgressBar(largeur_ecran - (bar_emptyHUD:getWidth() + 50), 20, 405, 43, 100, {50,50,50}, {250, 129, 50})

  barHeroHUD:setImages(bar_emptyHUD, bar_fullHUD)
  barDemonHUD:setImages(bar_emptyHUD, bar_fullHUD)
  
  groupHPHUD = myGUI:newGroup()
  groupHPHUD:addElement(barHeroHUD)
  groupHPHUD:addElement(barDemonHUD)
  
  background.y = (hauteur_ecran - background[fields[1]].back[1]:getHeight())/2
  frontLeft.speed = 20
  frontRight.speed = 20
  frontLeft.x = largeur_ecran/2
  frontRight.x = largeur_ecran/2
  
  music = love.audio.newSource("resources/sons/battle.wav","static")
  music:setVolume(0.5)
  music:setLooping(true)  
  
  hit = love.audio.newSource("resources/sons/hit.flac","static")
  hit:setVolume(0.2)
end

-- Chargement des textures des units
function Battle.LoadUnits(pTypes)
  for index, currentType in ipairs(pTypes) do
    tileSheet[currentType] = {}
    tileSheet[currentType].img = love.graphics.newImage("resources/images/battle/unit/"..currentType.."_tilesheet.png")
    tileSheet[currentType].width = tileSheet[currentType].img:getWidth()
    tileSheet[currentType].height = tileSheet[currentType].img:getHeight()
    tileSheet[currentType].tileWidth = tileSheet[currentType].width / nbTileCol
    tileSheet[currentType].tileHeight = tileSheet[currentType].height / nbTileLine
    tileSheet[currentType].ox = tileSheet[currentType].tileWidth/2
    tileSheet[currentType].oy = tileSheet[currentType].tileHeight
    tileSheet[currentType].sprite = {}
    tileSheet[currentType].sprite[0] = nil
    local l,c
    local id = 1
    for l=1,nbTileLine do
      for c=1,nbTileCol do
        tileSheet[currentType].sprite[id] = love.graphics.newQuad(
                                                    (c-1) * tileSheet[currentType].tileWidth,
                                                    (l-1) * tileSheet[currentType].tileHeight,
                                                    tileSheet[currentType].tileWidth,
                                                    tileSheet[currentType].tileHeight,
                                                    tileSheet[currentType].width,
                                                    tileSheet[currentType].height)
        id = id + 1
      end
    end
  end
end

function Battle.Start(pHero, pDemon, pTurn, pFieldHero, pFieldDemon)
  Battle.play = true
  music:play()
  isShaking = false
  backToMAP = false
  t = 0
  shakeDuration = -1
  shakeMagnitude = 0
  Battle.Init()
  hero = pHero
  demon = pDemon
  turn = pTurn
  fieldHero = pFieldHero
  fieldDemon = pFieldDemon
  bonusHeroField = Heros.dbHeros[hero.type].Effect[fieldHero] 
  
    -- Chargement bonus/malus de terrain
  local hpHero = (hero.HP / Heros.dbHeros[hero.type].HP) * 100
  local hpDemon = (demon.HP / Demons.dbDemons[demon.type].HP) * 100
  barHeroHUD:setValue(hpHero)
  barDemonHUD:setValue(hpDemon)

  -- Création des unites heros
  local n
  for n=1,hero.unitNombre do
    local unit
    if turn == "HERO" then
      unit = Battle.CreateSprite(hero.type, -largeur_ecran/2, positions[n].x, positions[n].y, "RUN")
    else
      unit = Battle.CreateSprite(hero.type, positions[n].x, positions[n].x, positions[n].y, "IDLE")
    end
    table.insert(list_heros, unit)
  end
  
  -- Création des unites demons
  for n=1,demon.unitNombre do
    local unit
    if turn == "DEMON" then
      unit = Battle.CreateSprite(demon.type, 1.5*largeur_ecran, largeur_ecran - positions[n].x, positions[n].y, "RUN")
    else
      unit = Battle.CreateSprite(demon.type, largeur_ecran - positions[n].x, 
                                 largeur_ecran - positions[n].x, positions[n].y, "IDLE")
    end
    table.insert(list_demons, unit)
  end
end

-- Dessine le combat
function Battle.Draw()
  love.graphics.setColor(0.2,0.2,0.2, 0.5)
  love.graphics.rectangle("fill", 0, 0, largeur_ecran, hauteur_ecran)
  love.graphics.setColor(1,1,1,1)
  
  if t < shakeDuration then
      local dx = love.math.random(-shakeMagnitude, shakeMagnitude)
      local dy = love.math.random(-shakeMagnitude, shakeMagnitude)
      love.graphics.translate(dx, dy)
  end
  love.graphics.setColor(1, 1, 1, 1)
  -- Dessine les backs
  love.graphics.draw(background[fieldHero].back[1], 
                     largeur_ecran/2, background.y, 0, 1, 1, 
                     background[fieldHero].back[1]:getWidth(), 0)
  love.graphics.draw(background[fieldDemon].back[2], largeur_ecran/2, background.y)
  
  -- Dessine les heros
  for index, unit in ipairs(list_heros) do
    local currentSprite = unit.tileSprite[math.floor(unit.currentImage)]
    if currentSprite ~= nil then
      love.graphics.draw(unit.tileSheet, currentSprite,
                         unit.x, unit.y, 0, 1, 1, 
                         tileSheet[unit.type].ox, tileSheet[unit.type].oy)
    end
  end
  
  -- Dessine les demons
  for index, unit in ipairs(list_demons) do
    local currentSprite = unit.tileSprite[math.floor(unit.currentImage)]
    if currentSprite ~= nil then
      love.graphics.draw(unit.tileSheet, currentSprite,
                         unit.x, unit.y, 0, -1, 1,
                         tileSheet[unit.type].ox, tileSheet[unit.type].oy)
    end
  end
  
  -- Dessine les fronts
  love.graphics.draw(background[fieldHero].front[1],frontLeft.x, background.y, 0, 1, 1, 
                     background[fieldHero].front[1]:getWidth(), 0)
  love.graphics.draw(background[fieldDemon].front[2], frontRight.x, background.y)
  groupHPHUD:draw()
  love.graphics.setColor(0.1, 0.1, 0.1)
  love.graphics.rectangle("fill", largeur_ecran/2 - 10,  background.y, 20, background[fields[1]].back[1]:getHeight())
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(hero.HP, 5, barHeroHUD.Y + 10, 0, 0.6, 0.6)
  love.graphics.print(demon.HP, largeur_ecran -50 , barDemonHUD.Y + 10, 0, 0.6, 0.6)
end

-- Update le combat
function Battle.Update(dt)
  
  if backToMAP then
    Battle.BackToMAP()
  else
    -- Animation des fronts
    frontLeft.x = frontLeft.x + frontLeft.speed * dt
    if frontLeft.x <= (largeur_ecran/2)-10 then
      frontLeft.x = (largeur_ecran/2)-10
      frontLeft.speed = frontLeft.speed * (-1)
    elseif frontLeft.x >= largeur_ecran/2 then
      frontLeft.x = largeur_ecran/2
      frontLeft.speed = frontLeft.speed * (-1)
    end
    
    frontRight.x = frontRight.x + frontRight.speed * dt
    if frontRight.x >= (largeur_ecran/2)+10 then
      frontRight.x = (largeur_ecran/2)+10
      frontRight.speed = frontRight.speed * (-1)
    elseif frontRight.x <= largeur_ecran/2 then
      frontRight.x = largeur_ecran/2
      frontRight.speed = frontRight.speed * (-1)
    end
    
    -- Animation des unites
    Battle.AnimationUnits(list_heros, list_demons, dt)
    Battle.AnimationUnits(list_demons, list_heros, dt)
    
    -- Si attaquants pas en place
    if not unitsFixed then
      Battle.AnimationArrivalUnits(dt)
    else
      -- Shake
      if t < shakeDuration then
        t = t + dt
      else
        isShaking = false
      end
      Battle.ManageHPUnits(dt)
      -- Gestion de l'attaque de l'unite
      timer = timer + 5 * dt
      if timer >= 10 then
        timer = 0
        if count < 3 then
          if turn == "HERO" then
            loseHP = math.floor(hero.force*bonusHeroField)
            for index, hero in ipairs(list_heros) do
              hero.nextAnim = "ATTACK"
            end
          elseif turn == "DEMON" then
            loseHP = math.floor(demon.force/bonusHeroField)
            for index, demon in ipairs(list_demons) do
              demon.nextAnim = "ATTACK"
            end
          end
          count = count + 1
        end
      end
    end
  end
end

function Battle.AnimationUnits(units, unitsEnnemi, dt)
  for index, unit in ipairs(units) do
    if unit.currentImage >= animations[unit.currentAnim].frame + 5 and unit.currentAnim == "HIT" and loseHP > 0 then
      Battle.StartShake(0.3, 3)
      hit:play()
      Battle.LoseHP()
    end
    if unit.currentAnim == unit.nextAnim then
      unit.currentImage = unit.currentImage + unit.animSpeed * dt
      if unit.currentImage >= animations[unit.currentAnim].frame + 10 then
        if unit.currentAnim == "DIE" or (count >= 3 and unit.nextAnim ~= "ATTACK" and unit.nextAnim ~= "HIT" and loseHP == 0) then
          backToMAP = true
        end
        if not animations[unit.currentAnim].loop then
          if unit.currentAnim == "ATTACK" then
            for index, unitEnnemi in ipairs(unitsEnnemi) do
              unitEnnemi.nextAnim = "HIT"
            end
          end
          unit.nextAnim = "IDLE"
          unit.currentAnim = "IDLE"
          unit.currentImage = animations["IDLE"].frame
        else
          unit.currentImage = animations[unit.currentAnim].frame
        end
      end
    else
      unit.currentAnim = unit.nextAnim
      unit.currentImage = animations[unit.currentAnim].frame
    end
  end
end

function Battle.AnimationArrivalUnits(dt)
  local fixed = true
  -- Arrivée des heros
  for index, hero in ipairs(list_heros) do
    if hero.x >= hero.finalX then
      hero.x = hero.finalX
      hero.nextAnim = "IDLE"
    else
      hero.x = hero.x + hero.moveSpeed * dt
      fixed = false
    end
  end
  -- Arrivée des demons
  for index, demon in ipairs(list_demons) do
    if demon.x <= demon.finalX then
      demon.x = demon.finalX
      demon.nextAnim = "IDLE"
    else
      demon.x = demon.x - demon.moveSpeed * dt
      fixed = false
    end
  end
  unitsFixed = fixed
end

function Battle.ManageHPUnits(dt)
  -- Gestion points de vie du hero
  local hpHero = (hero.HP / Heros.dbHeros[hero.type].HP) * 100
  if hpHero < barHeroHUD.Value then
    local value = barHeroHUD.Value - hpSpeed *dt
    if value <= 0 then
      value = 0
      hero.dead = true
      for index, hero in ipairs(list_heros) do
        if hero.nextAnim ~= "DIE" then
          hero.nextAnim = "DIE"
        end
      end
    end
    barHeroHUD:setValue(value)
  end
  -- Gestion points de vie du demon
  local hpDemon = (demon.HP / Demons.dbDemons[demon.type].HP) * 100
  if hpDemon < barDemonHUD.Value then
    local value = barDemonHUD.Value - hpSpeed *dt
    if value <= 0 then
      value = 0
      demon.dead = true
      for index, demon in ipairs(list_demons) do
        if demon.nextAnim ~= "DIE" then
          demon.nextAnim = "DIE"
        end
      end
    end
    barDemonHUD:setValue(value)
  end
  groupHPHUD:update(dt)
end

-- Perte de vie
function Battle.LoseHP()
  if turn == "HERO" then
    demon.HP = demon.HP - loseHP
    if demon.HP <= 0 then
      demon.HP = 0
    end
  else
    hero.HP = hero.HP - loseHP
    if hero.HP <= 0 then
      hero.HP = 0
    end
  end
  loseHP = 0
end

-- Retour sur la map
function Battle.BackToMAP()
  music:stop()
  Battle.play = false
--  Screen = "MAP"
--  Etat = "SELECTION"
end

return Battle