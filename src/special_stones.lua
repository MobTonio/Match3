-- Special Stones Module - Модуль специальных камней

local SpecialStones = {}
SpecialStones.__index = SpecialStones

local STONE_TYPES = {}

-- Конструктор
function SpecialStones:new()
    local instance = {
        stones = {},
        effects = {}
    }
    setmetatable(instance, self)
    return instance
end

-- Создает новый специальный камень
function SpecialStones:createStone(x, y, stone_type)
    local stone = {
        x = x,
        y = y,
        type = stone_type
    }
    
    table.insert(self.stones, stone)
    return stone
end

-- Определяет тип специального камня на основе позиций совпадений
function SpecialStones:determineStoneType(match_positions)
end

-- Удаляет специальный камень
function SpecialStones:removeStone(stone)
    for i, s in ipairs(self.stones) do
        if s == stone then
            table.remove(self.stones, i)
            break
        end
    end
end

-- Опускает специальные камни на позиции после удаления
function SpecialStones:drop(deletedPositions)
end

-- Получить типы камней для внешнего использования
function SpecialStones:getStoneTypes()
    return STONE_TYPES
end

return SpecialStones
