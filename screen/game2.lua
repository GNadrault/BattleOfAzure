local Game = {}

local Map = require("screen/game/map")
local Battle = require("screen/game/battle")
local Finish = require("screen/game/finish")

current_game = nil

function Game.Load()
  current_game = "map"
end


function Game.Update(dt)
  if current_game == "map" then
    Map.Update(dt)
  elseif current_game == "battle" then
    Battle.Update(dt)
  elseif current_game == "finish" then
    Finish.Update(dt)
  end
end


function Game.Draw()
  if current_game == "map" then
    Map.Draw()
  elseif current_game == "battle" then
    Battle.Draw()
  elseif current_game == "finish" then
    Finish.Update(dt)
  end
end




return Game