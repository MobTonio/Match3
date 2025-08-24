-- GameField Positioning Module - Модуль позиционирования на игровом поле
-- Отвечает за определение позиций для различных эффектов

local GameFieldPositioning = {}
GameFieldPositioning.__index = GameFieldPositioning

function GameFieldPositioning:new(field_size)
    local instance = {
        field_size = field_size or 10
    }
    setmetatable(instance, self)
    return instance
end

-- Проверить, является ли позиция валидной
function GameFieldPositioning:isValidPosition(x, y)
    return x >= 0 and x < self.field_size and y >= 0 and y < self.field_size
end

-- Фильтровать позиции, оставляя только валидные
function GameFieldPositioning:filterValidPositions(positions)
    local valid_positions = {}
    
    for _, pos in ipairs(positions) do
        if self:isValidPosition(pos.x, pos.y) then
            table.insert(valid_positions, pos)
        end
    end
    
    return valid_positions
end

-- Объединить несколько наборов позиций, исключая дубликаты
function GameFieldPositioning:mergePositions(...)
    local merged = {}
    local seen = {}
    
    for _, position_set in ipairs({...}) do
        for _, pos in ipairs(position_set) do
            local key = pos.x .. "," .. pos.y
            if not seen[key] then
                seen[key] = true
                table.insert(merged, pos)
            end
        end
    end
    
    return merged
end

-- Преобразует направление в целевые координаты
function GameFieldPositioning:directionToCoordinates(from, direction)
    local to_x, to_y = from.x, from.y
    
    if direction == "l" and from.x > 0 then
        to_x = from.x - 1
    elseif direction == "r" and from.x < self.field_size - 1 then
        to_x = from.x + 1
    elseif direction == "u" and from.y > 0 then
        to_y = from.y - 1
    elseif direction == "d" and from.y < self.field_size - 1 then
        to_y = from.y + 1
    else
        return nil -- Недопустимое направление или выход за границы
    end
    
    -- Проверяем валидность обеих позиций
    if self:isValidPosition(from.x, from.y) and self:isValidPosition(to_x, to_y) then
        return {x = to_x, y = to_y}
    end
    
    return nil
end

return GameFieldPositioning
