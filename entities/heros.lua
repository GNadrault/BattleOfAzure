local Heros = {}

Heros.list_heros = {}
Heros.dbHeros = {}
Heros.frameSpeed = 6
Heros.moveSpeed = 6
Heros.battle = {}
Heros.typeHero = {"ARCHER","KNIGHT","WIZARD"}

function Heros.CreeHero(pType, pLine, pCol)
  local hero = {}
  hero.dead = false
  hero.active = true
  hero.type = pType
  hero.line = pLine
  hero.col = pCol 
  hero.type = pType
  hero.force = Heros.dbHeros[pType].Force
  hero.HP = Heros.dbHeros[pType].HP
  hero.PM = Heros.dbHeros[pType].PM
  hero.PA = Heros.dbHeros[pType].PA
  hero.currentImage = 1
  hero.currentAnim = "Idle"
  hero.unitNombre  = math.random(2,3) -- nombre aléatoire entre 2 et 3 heros 
  table.insert(Heros.list_heros, hero)
end

function Heros.Load()
  Heros.dbHeros["ARCHER"] = {}
  Heros.dbHeros["ARCHER"].HP = 200
  Heros.dbHeros["ARCHER"].PM = 6
  Heros.dbHeros["ARCHER"].PA = 6
  Heros.dbHeros["ARCHER"].Force = 16
  Heros.dbHeros["ARCHER"].Image = {}
  Heros.dbHeros["ARCHER"].Image["Idle"] = {}
  Heros.dbHeros["ARCHER"].Image["Walk"] = {}
  Heros.dbHeros["ARCHER"].Image["Death"] = {}
  Heros.dbHeros["ARCHER"].Effect = {}
  Heros.dbHeros["ARCHER"].Effect["PLAIN"] = 1
  Heros.dbHeros["ARCHER"].Effect["FOREST"]= 2
  Heros.dbHeros["ARCHER"].Effect["MOUNTAIN"]= 0.5
  for k, v in pairs(Heros.dbHeros["ARCHER"].Image) do
    for n=1,4 do
      Heros.dbHeros["ARCHER"].Image[k][n] = love.graphics.newImage("resources/images/hero/ARCHER/Hunter"..k.."(Frame "..n..").png")
    end
  end
  
  Heros.dbHeros["KNIGHT"] = {}
  Heros.dbHeros["KNIGHT"].HP = 250
  Heros.dbHeros["KNIGHT"].PM = 3
  Heros.dbHeros["KNIGHT"].PA = 2
  Heros.dbHeros["KNIGHT"].Force = 20
  Heros.dbHeros["KNIGHT"].Image = {}
  Heros.dbHeros["KNIGHT"].Image["Idle"] = {}
  Heros.dbHeros["KNIGHT"].Image["Walk"] = {}
  Heros.dbHeros["KNIGHT"].Image["Death"] = {}
  Heros.dbHeros["KNIGHT"].Effect = {}
  Heros.dbHeros["KNIGHT"].Effect["PLAIN"] = 2
  Heros.dbHeros["KNIGHT"].Effect["FOREST"]= 0.7
  Heros.dbHeros["KNIGHT"].Effect["MOUNTAIN"]= 0.5
  for k, v in pairs(Heros.dbHeros["KNIGHT"].Image) do
    for n=1,4 do
      Heros.dbHeros["KNIGHT"].Image[k][n] = love.graphics.newImage("resources/images/hero/KNIGHT/Swordsman"..k.."(Frame "..n..").png")
    end
  end
  
  Heros.dbHeros["WIZARD"] = {}
  Heros.dbHeros["WIZARD"].HP = 180
  Heros.dbHeros["WIZARD"].PM = 4
  Heros.dbHeros["WIZARD"].PA = 5
  Heros.dbHeros["WIZARD"].Force = 30
  Heros.dbHeros["WIZARD"].Effect = {}
  Heros.dbHeros["WIZARD"].Image = {}
  Heros.dbHeros["WIZARD"].Image["Idle"] = {}
  Heros.dbHeros["WIZARD"].Image["Walk"] = {}
  Heros.dbHeros["WIZARD"].Image["Death"] = {}
  Heros.dbHeros["WIZARD"].Effect = {}
  Heros.dbHeros["WIZARD"].Effect["PLAIN"] = 1
  Heros.dbHeros["WIZARD"].Effect["FOREST"]= 0.5
  Heros.dbHeros["WIZARD"].Effect["MOUNTAIN"]= 2
  for k, v in pairs(Heros.dbHeros["WIZARD"].Image) do
    for n=1,4 do
      Heros.dbHeros["WIZARD"].Image[k][n] = love.graphics.newImage("resources/images/hero/WIZARD/Druid"..k.."(Frame "..n..").png")
    end
  end
end


function Heros.getHeroAt(pLine, pCol) 
  for n=1,#Heros.list_heros do
    local currentHero = Heros.list_heros[n]
    if pCol == currentHero.col and pLine == currentHero.line then
      return currentHero
    end
  end
  return nil
end

function Heros.ResetPoints()
  for index, value in ipairs(Heros.list_heros) do
    value.PM = Heros.dbHeros[value.type].PM
    value.active = true
  end
end


return Heros