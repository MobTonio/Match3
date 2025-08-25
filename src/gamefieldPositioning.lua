-- GameField Positioning Module
local GameFieldPositioning = {}
GameFieldPositioning.__index = GameFieldPositioning

-- Создание нового экземпляра
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
