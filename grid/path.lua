local Path = {}

local Node = require("grid/node")
local Map = require("map/map")
local Utils = require("utils/utils")
local Heros = require("entities/heros")
local Demons = require("entities/demons")

local openList = {}
local closeList = {}

function Path.FindPath(pLineE, pColE, pLineS, pColS)
  -- Init des listes
  openList = {}
  closeList = {}
  
  -- Ajout du noeud de départ dans openList
  local rootNode = Node:new(nil, pLineE, pColE, 0, 0, 0)
  table.insert(openList, rootNode)
  
  local finalNode = nil
  while next(openList) ~= nil and finalNode == nil do
    -- Recherche du plus petit F dans openList
    local currentNode = openList[1]
    local indexCurrentNode = 1
    for index, valeur in ipairs(openList) do
      if valeur.f < currentNode.f then
        currentNode = valeur
        indexCurrentNode = index
      end
    end
    
    -- Retire le plus petit F openList
    table.remove(openList, indexCurrentNode)
    -- Générer les 8 successeurs
    finalNode = Path.FindAroundNode(currentNode, pLineS, pColS)
    -- Ajout du noeud courant dans closeList
    table.insert(closeList, currentNode)
  end
  return finalNode
end

function Path.FindAroundNode(currentNode, pLineS, pColS)
  for l=currentNode.line - 1, currentNode.line + 1 do
    for c=currentNode.col - 1, currentNode.col + 1 do
      if (l == currentNode.line and c == currentNode.col) == false then
        if not Map.isObstacle(l+1, c+1) then
          if Heros.getHeroAt(l,c) == nil and Demons.getDemonAt(l,c) == nil then
            -- Instanciation d'un nouveau noeud
            local node = Node:new(currentNode, l, c, 0, 0, 0)
            node:calculG(currentNode)
            node:calculH(pLineS, pColS)
            node:calculF()
            
            -- Si noeud == noeud final alors fin de la recherche
            if node.line == pLineS and node.col == pColS then
              return node
            else
              -- Vérification s'il est déjà dans openList
              local posOpenList = Utils.getPosInTable(l, c, openList)
              if posOpenList == 0 or openList[posOpenList].f > node.f then
                -- Vérification s'il est déjà dans closeList
                local posCloseList = Utils.getPosInTable(l, c, closeList)
                if posCloseList == 0 or closeList[posCloseList].f > node.f then
                  table.insert(openList, node)
                end
              end
            end
          end
        end
      end
    end
  end
  return nil
end

return Path