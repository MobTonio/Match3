-- Special Stones Module - Модуль специальных камней

local SpecialStones = {}
local Field_size = 10
SpecialStones.__index = SpecialStones

local STONE_TYPES = {
    BOMB = "bomb",
    LINE_H = "line_h",
    LINE_V = "line_v",
    RAINBOW = "rainbow"
}

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
    local match_size = #match_positions
    
    if match_size == 4 then
        return self:isHorizontalMatch(match_positions) and STONE_TYPES.LINE_H or STONE_TYPES.LINE_V
    elseif match_size == 5 then
        return STONE_TYPES.RAINBOW
    elseif match_size >= 6 then
        return STONE_TYPES.BOMB
    end
    
    return nil 
end

function SpecialStones:isHorizontalMatch(positions)
    if #positions < 2 then return false end
    
    local first_y = positions[1].y
    for i = 2, #positions do
        if positions[i].y ~= first_y then
            return false
        end
    end
    return true
end

function SpecialStones:activateStone(stone, field)
    local effect = {
        type = stone.type,
        x = stone.x,
        y = stone.y,
        positions_to_destroy = {}
    }
    
    if stone.type == STONE_TYPES.BOMB then
        effect.positions_to_destroy = self:getBombArea(stone.x, stone.y, field)
    elseif stone.type == STONE_TYPES.LINE_H then
        effect.positions_to_destroy = self:getRowPositions(stone.y, field)
    elseif stone.type == STONE_TYPES.LINE_V then
        effect.positions_to_destroy = self:getColumnPositions(stone.x, field)
    elseif stone.type == STONE_TYPES.RAINBOW then
        effect.positions_to_destroy = self:getColorPositions(field, stone.target_color)
    end
    
    table.insert(self.effects, effect)
    return effect
end

function SpecialStones:getBombArea(center_x, center_y, field)
    local positions = {}
    
    for dy = -1, 1 do
        for dx = -1, 1 do
            local x = center_x + dx
            local y = center_y + dy
            
            if x >= 0 and x < Field_size and y >= 0 and y < Field_size then
                table.insert(positions, {x = x, y = y})
            end
        end
    end
    
    return positions
end

function SpecialStones:getRowPositions(y, field)
    local positions = {}
    
    for x = 0, Field_size - 1 do
        table.insert(positions, {x = x, y = y})
    end
    
    return positions
end

function SpecialStones:getColumnPositions(x, field)
    local positions = {}
    
    for y = 0, Field_size - 1 do
        table.insert(positions, {x = x, y = y})
    end
    
    return positions
end

function SpecialStones:getColorPositions(field, target_color)
    local positions = {}
    
    for y = 0, Field_size - 1 do
        for x = 0, Field_size - 1 do
            if field[y][x] == target_color then
                table.insert(positions, {x = x, y = y})
            end
        end
    end
    
    return positions
end

function SpecialStones:clearEffects()
    self.effects = {}
end

function SpecialStones:hasStoneAt(x, y)
    for _, stone in ipairs(self.stones) do
        if stone.x == x and stone.y == y then
            return stone
        end
    end
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

return SpecialStones
