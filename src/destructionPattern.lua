-- Destruction Pattern Module - Модуль паттернов уничтожения

local GameFieldPositioning = require("src.gamefieldPositioning")

local DestructionPattern = {}
DestructionPattern.__index = DestructionPattern

local PATTERN_TYPES = {
    MATCHES = "matches"
}

function DestructionPattern:new(field_size)
    local instance = {
        field_size = field_size or 10,
        positioning = GameFieldPositioning:new(field_size or 10)
    }
    setmetatable(instance, self)
    return instance
end

-- Основная функция для получения позиций по паттерну
function DestructionPattern:getPositions(pattern, context)
    local pattern_type = pattern.type
end

-- Получить доступные типы паттернов
function DestructionPattern:getPatternTypes()
    return PATTERN_TYPES
end

-- Объединить несколько паттернов в один
function DestructionPattern:combinePatterns(patterns, context)
    local all_positions = {}
    
    for _, pattern in ipairs(patterns) do
        local positions = self:getPositions(pattern, context)
        for _, pos in ipairs(positions) do
            table.insert(all_positions, pos)
        end
    end
    
    return self.positioning:mergePositions(all_positions)
end

return DestructionPattern
