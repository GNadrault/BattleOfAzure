local Demons = {}

Demons.list_demons = {}
Demons.dbDemons = {}
Demons.frameSpeed = 6
Demons.moveSpeed = 6
Demons.battle = {}
Demons.typeDemon = {"GOBLIN","TROLL","DEVIL"}

function Demons.CreeDemon(pType, pLine, pCol)
  local demon = {}
  demon.dead = false
  demon.active = true
  demon.type = pType
  demon.line = pLine
  demon.col = pCol
  demon.force = Demons.dbDemons[pType].Force
  demon.HP = Demons.dbDemons[pType].HP
  demon.PM = Demons.dbDemons[pType].PM
  demon.PA = Demons.dbDemons[pType].PA
  demon.currentImage = 1
  demon.currentAnim = "Idle"
  demon.unitNombre = math.random(2,3) -- nombre aléatoire entre 2 et 3 demons
  table.insert(Demons.list_demons, demon)
end

function Demons.Load()
  Demons.dbDemons["DEVIL"] = {}
  Demons.dbDemons["DEVIL"].HP = 230
  Demons.dbDemons["DEVIL"].PM = 3
  Demons.dbDemons["DEVIL"].PA = 5
  Demons.dbDemons["DEVIL"].Force = 23
  Demons.dbDemons["DEVIL"].Image = {}
  Demons.dbDemons["DEVIL"].Image["Idle"] = {}
  Demons.dbDemons["DEVIL"].Image["Walk"] = {}
  Demons.dbDemons["DEVIL"].Image["Death"] = {}
  for k, v in pairs(Demons.dbDemons["DEVIL"].Image) do
    for n=1,4 do
      Demons.dbDemons["DEVIL"].Image[k][n] = love.graphics.newImage("resources/images/demon/DEVIL/Devil"..k.."(Frame "..n..").png")
    end
  end
  
  Demons.dbDemons["GOBLIN"] = {}
  Demons.dbDemons["GOBLIN"].HP = 150
  Demons.dbDemons["GOBLIN"].PM = 6
  Demons.dbDemons["GOBLIN"].PA = 5
  Demons.dbDemons["GOBLIN"].Force = 13
  Demons.dbDemons["GOBLIN"].Image = {}
  Demons.dbDemons["GOBLIN"].Image["Idle"] = {}
  Demons.dbDemons["GOBLIN"].Image["Walk"] = {}
  Demons.dbDemons["GOBLIN"].Image["Death"] = {}
  for k, v in pairs(Demons.dbDemons["GOBLIN"].Image) do
    for n=1,4 do
      Demons.dbDemons["GOBLIN"].Image[k][n] = love.graphics.newImage("resources/images/demon/GOBLIN/Goblin"..k.."(Frame "..n..").png")
    end
  end
  
  Demons.dbDemons["TROLL"] = {}
  Demons.dbDemons["TROLL"].HP = 200
  Demons.dbDemons["TROLL"].PM = 2
  Demons.dbDemons["TROLL"].PA = 5
  Demons.dbDemons["TROLL"].Force = 20
  Demons.dbDemons["TROLL"].Image = {}
  Demons.dbDemons["TROLL"].Image["Idle"] = {}
  Demons.dbDemons["TROLL"].Image["Walk"] = {}
  Demons.dbDemons["TROLL"].Image["Death"] = {}
  for k, v in pairs(Demons.dbDemons["TROLL"].Image) do
    for n=1,4 do
      Demons.dbDemons["TROLL"].Image[k][n] = love.graphics.newImage("resources/images/demon/TROLL/Troll"..k.."(Frame "..n..").png")
    end
  end
end

function Demons.getDemonAt(pLine, pCol) 
  for n=1,#Demons.list_demons do
    local currentDemon = Demons.list_demons[n]
    if pCol == currentDemon.col and pLine == currentDemon.line then
      return currentDemon
    end
  end
  return nil
end

function Demons.ResetPoints()
  for index, value in ipairs(Demons.list_demons) do
    value.PM = Demons.dbDemons[value.type].PM
    value.active = true
  end
end

return Demons