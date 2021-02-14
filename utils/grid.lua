local Grid = {}

local Path = require("grid/path")
local Node = require("grid/node")

Grid.Background = 
            {
              {15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,26,25},
              {15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15},
              {15,15,15,15,15,15,15,15,18,17,23,23,23,23,23,23,23,19,15,15,18,17,19,15,15,15,15,15,15,15,15,15},
              {15,15,15,15,15,15,15,18,29,9,9,9,9,9,9,12,13,28,19,18,29,9,28,23,19,15,15,15,15,15,15,15},
              {15,15,18,19,18,17,23,29,9,2,3,9,9,9,9,9,2,3,28,24,9,9,9,9,28,23,19,15,15,15,15,15},
              {15,15,26,27,16,9,4,9,9,9,9,9,9,9,20,7,21,12,4,9,11,9,9,9,9,11,28,19,15,15,15,15},
              {15,15,15,18,29,9,9,3,9,9,9,9,9,9,14,32,26,21,13,9,9,9,9,2,3,12,9,31,15,15,15,15},
              {15,15,15,30,4,9,35,42,42,36,9,9,9,9,28,23,23,29,9,9,9,9,9,10,9,9,9,28,19,15,15,15},
              {15,15,15,30,9,10,41,2,11,41,9,9,9,10,9,9,9,20,21,9,9,9,9,9,9,9,9,9,22,19,15,15},
              {15,15,18,29,9,35,44,3,4,41,9,9,9,9,9,9,9,28,29,9,9,9,9,9,9,9,9,9,9,28,19,15},
              {15,18,29,9,9,41,9,10,9,37,42,42,42,36,9,9,9,9,11,9,9,9,9,9,9,9,9,9,9,4,31,15},
              {15,16,9,9,9,41,10,9,9,41,9,9,10,43,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,11,31,15},
              {15,30,9,9,9,41,9,9,9,41,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,2,3,20,27,15},
              {15,26,21,2,3,43,42,42,42,44,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,11,9,31,15,15},
              {15,15,26,25,21,9,9,9,9,3,4,10,9,20,7,21,9,9,9,9,9,9,9,9,9,9,9,9,9,28,19,15},
              {15,15,15,15,26,21,9,9,9,9,3,4,9,14,32,16,9,9,9,9,9,9,9,9,9,9,9,9,9,9,14,15},
              {15,15,15,15,15,30,9,9,9,9,9,9,9,14,32,16,9,9,9,9,11,9,9,9,12,13,9,9,12,20,27,15},
              {15,15,15,15,18,24,9,9,9,9,9,9,9,28,23,29,9,9,9,9,9,9,9,9,3,4,9,9,20,27,15,15},
              {15,15,15,15,16,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,31,15,15,15},
              {15,15,15,15,16,9,9,9,9,9,9,9,9,9,9,9,11,9,9,9,9,9,9,9,9,2,20,7,27,15,15,15},
              {15,15,15,15,26,21,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,13,2,3,9,14,15,15,18,17,19},
              {15,15,15,15,15,26,7,7,7,8,9,20,21,9,9,3,4,9,9,9,9,9,9,9,4,9,28,19,15,30,3,31},
              {15,15,15,15,15,15,15,15,15,26,25,27,26,25,7,7,21,9,9,12,20,7,21,9,9,12,20,27,15,26,25,27},
              {15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,26,7,7,25,27,15,26,7,7,25,27,15,15,15,15,18}            
            }

Grid.Foreground = 
            {
              {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,107,108,109,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,130,130,155,156,157,0,0,0,0,0,115,116,117,180,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,131,132,133,0,0,0,163,164,165,0,0,0,0,0,123,124,128,110,112,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,139,140,141,50,51,60,171,172,173,0,0,0,0,154,0,180,57,126,128,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,147,148,149,0,0,65,0,130,0,0,0,0,0,154,154,0,65,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,130,65,0,0,0,0,0,0,154,154,154,0,65,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,130,65,0,0,0,183,184,0,0,107,108,109,65,0,130,106,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,130,65,0,154,154,191,192,0,0,115,116,117,74,51,60,130,131,132,133,0,0,0},
              {0,0,155,156,157,0,130,0,0,0,0,54,0,0,158,156,160,0,0,123,124,125,181,182,65,0,139,140,141,0,0,0},
              {0,0,163,164,165,0,0,57,130,0,130,65,0,0,163,164,162,156,157,154,154,0,189,190,65,0,147,148,149,0,0,0},
              {0,0,171,172,173,0,130,65,130,0,130,65,180,0,174,172,175,172,173,58,51,59,75,51,75,60,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,54,131,132,133,74,59,51,51,51,59,51,51,76,180,65,131,132,133,73,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,65,139,140,141,0,65,0,0,0,73,134,132,133,154,73,139,140,141,183,184,0,183,184,0,0},
              {0,0,0,0,0,0,0,65,147,148,149,0,65,0,0,0,129,139,140,141,82,82,147,148,149,191,192,0,191,192,0,0},
              {0,0,0,0,0,0,0,74,51,51,51,51,68,0,0,0,57,147,148,149,0,154,154,154,0,0,154,0,0,0,0,0},
              {0,0,0,0,0,0,183,184,180,155,156,157,73,0,0,0,65,158,156,157,154,183,184,154,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,191,192,0,163,164,165,180,50,51,51,76,163,164,165,154,191,192,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,154,171,172,173,131,132,133,0,0,171,172,173,154,0,0,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,0,130,139,140,141,0,0,154,0,0,183,184,0,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,0,0,147,148,149,0,0,0,0,0,191,192,0,0,0,0,0,0,0,0,180,0},
              {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
              {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
            }

Grid.MAP_WIDTH = 32
Grid.MAP_HEIGHT = 24
Grid.TILE_WIDTH = 16
Grid.TILE_HEIGHT = 16

Grid.Obstacle = {6,7,8,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,35,36,37,38,39,40,41,42,43,44,45,46,47,48}

Grid.Forest = {82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152}

Grid.Mountain = {154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,181,182,183,184,189,190,191,192}


function Grid.isObstacle(pLine, pCol)
  local obstacleBack = Utils.has_value(Map.Obstacle, Map.Background[pLine][pCol])
  local obstacleFront = Utils.has_value(Map.Obstacle, Map.Foreground[pLine][pCol]) 
  return obstacleFront or (obstacleBack and Map.Foreground[pLine][pCol] == 0)
end

function Grid.GetField(pLine, pCol)
  if Utils.has_value(Map.Forest, Map.Foreground[pLine][pCol]) then
    return "FOREST"
  elseif Utils.has_value(Map.Mountain, Map.Foreground[pLine][pCol]) then
    return "MOUNTAIN"
  else
    return "PLAIN"
  end
end


-- Créer la grille de déplacement/d'action du personnage
function Grid.CreateGrid(pLine, pCol, move_distance)
  local starting_pos = Node:new(nil, pLine, pCol, 0, 0, 0)
  --local movePath = {}
  local moveGrid = {}
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
            if current_state == "move" then
              if Heros.getHeroAt(valeur.line,valeur.col) == nil and Demons.getDemonAt(valeur.line,valeur.col) == nil then
                table.insert(moveGrid, valeur)
              end
            elseif current_state == "action" then
              if current_turn == "hero" then
                if Heros.getHeroAt(valeur.line,valeur.col) == nil then
                  table.insert(moveGrid, valeur)
                end
              elseif current_turn == "demon" then
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
  return moveGrid
end

-- Creer le path le plus court du point de départ au point d'arrive
function Grid.CreatePath(startLine, startCol, endLine, endCol)
  local finalNode = Path.FindPath(startLine, startCol, endLine, endCol)
  local movePath = {}
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
  return movePath
end
return Grid