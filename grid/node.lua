local Node = {}

function Node:new(pNodeParent, pLine, pCol, pG, pH, pF)
  local node = {}
  setmetatable(node, self)
  self.__index = self
  node.parent = pNodeParent or nil
  node.line = pLine or 0
  node.col = pCol or 0
  node.g = pG or 0
  node.h = pH or 0
  node.f = pF or 0
	return node
end

function Node:printNode()
  print("Noeud : line = "..self.line.." col = "..self.col)
end

function Node:calculG(nodeParent)
  local valeur = 1.4
  if nodeParent.line == self.line or nodeParent.col == self.col then
    valeur = 1.0
  end
  self.g = nodeParent.g + valeur
end
  
function Node:calculH(pLineS, pColS)
  self.h = math.abs(pLineS - self.line) + math.abs(pColS - self.col)
end

function Node:calculF()
  self.f = self.g + self.h
end

return Node

