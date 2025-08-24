-- Special Stones Module - Модуль специальных камней

local SpecialStones = {}
SpecialStones.__index = SpecialStones

local STONE_TYPES = {}

function SpecialStones:new()
    local instance = {
        stones = {},
        effects = {}
    }
    setmetatable(instance, self)
    return instance
end

function SpecialStones:createStone(x, y, stone_type, match_size)
    local stone = {
        x = x,
        y = y,
        type = stone_type,
        created_from_match = match_size
    }
    
    table.insert(self.stones, stone)
    return stone
end

function SpecialStones:determineStoneType(match_positions)
    return nil 
end

function SpecialStones:removeStone(stone)
    for i, s in ipairs(self.stones) do
        if s == stone then
            table.remove(self.stones, i)
            break
        end
    end
end

-- Получить типы камней для внешнего использования
function SpecialStones:getStoneTypes()
    return STONE_TYPES
end

return SpecialStones
