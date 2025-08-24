-- Destruction Pattern Module - Модуль паттернов уничтожения
-- Отвечает за определение позиций кристаллов для различных паттернов уничтожения

local GameFieldPositioning = require("src.gamefieldPositioning")

local DestructionPattern = {}
DestructionPattern.__index = DestructionPattern

-- Типы паттернов уничтожения
local PATTERN_TYPES = {
    MATCHES = "matches"        -- Обычные совпадения 3+ в ряд
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
    
    if pattern_type == PATTERN_TYPES.MATCHES then
        return self:getMatchPositions(context)
    else
        return {}
    end
end

-- Паттерн: Обычные совпадения (3+ в ряд)
function DestructionPattern:getMatchPositions(context)
    local field_grid = context.field_grid
    
    if not field_grid then
        return {}
    end
    
    -- Здесь должна быть логика поиска совпадений
    -- Пока возвращаем пустой массив, так как эта логика уже есть в Field
    return {}
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
    
    -- Удаляем дубликаты
    return self.positioning:mergePositions(all_positions)
end

return DestructionPattern
