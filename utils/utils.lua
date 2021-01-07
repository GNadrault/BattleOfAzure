local Utils = {}

function Utils.has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function Utils.getPosInTable(pLine, pCol, table)
  for index, valeur in ipairs(table) do
    if valeur.line == pLine and valeur.col == pCol then
      return index
    end
  end
  return 0
end

function Utils.isEmptyTable(table)
  local next = next
  return next(table) == nil
end

function Utils.copyTable(table)
  local copy = {}
  for k,v in pairs(table) do
    copy[k] = v
  end
  return copy
end

return Utils