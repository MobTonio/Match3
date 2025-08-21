-- Game Model - Модель игры Match-3
-- Реализует логику игры с использованием ООП

local Game = {}
Game.__index = Game

local FIELD_SIZE = 10
local COLORS = {"A", "B", "C", "D", "E", "F"}
local MIN_MATCH = 3

function Game:new()
    local instance = {
        field = {},
        score = 0,
        changes_made = false
    }
    setmetatable(instance, self)
    return instance
end

function Game:init()
    self.field = {}
    self.score = 0
    
    for y = 0, FIELD_SIZE - 1 do
        self.field[y] = {}
        for x = 0, FIELD_SIZE - 1 do
            self.field[y][x] = self:getRandomColor()
        end
    end
    
    self:removeInitialMatches()
end

function Game:getRandomColor()
    return COLORS[math.random(1, #COLORS)]
end

function Game:removeInitialMatches()
    for y = 0, FIELD_SIZE - 1 do
        for x = 0, FIELD_SIZE - 1 do
            local color = self.field[y][x]
            
            local horizontal_count = 1
            for i = x + 1, FIELD_SIZE - 1 do
                if self.field[y][i] == color then
                    horizontal_count = horizontal_count + 1
                else
                    break
                end
            end
            
            local vertical_count = 1
            for i = y + 1, FIELD_SIZE - 1 do
                if self.field[i][x] == color then
                    vertical_count = vertical_count + 1
                else
                    break
                end
            end
            
            if horizontal_count >= MIN_MATCH or vertical_count >= MIN_MATCH then
                repeat
                    self.field[y][x] = self:getRandomColor()
                until self.field[y][x] ~= color
            end
        end
    end
end

function Game:getField()
    return self.field
end

function Game:move(x, y, direction)
    local new_x, new_y = x, y
    
    if direction == "l" and x > 0 then
        new_x = x - 1
    elseif direction == "r" and x < FIELD_SIZE - 1 then
        new_x = x + 1
    elseif direction == "u" and y > 0 then
        new_y = y - 1
    elseif direction == "d" and y < FIELD_SIZE - 1 then
        new_y = y + 1
    else
        return false
    end
    
    local temp = self.field[y][x]
    self.field[y][x] = self.field[new_y][new_x]
    self.field[new_y][new_x] = temp
    
    local matches_found = self:findMatches()
    
    if #matches_found == 0 then
        self.field[new_y][new_x] = self.field[y][x]
        self.field[y][x] = temp
        return false
    end
    
    return true
end

function Game:tick()
    self.changes_made = false
    
    local matches = self:findMatches()
    if #matches > 0 then
        self:removeMatches(matches)
        self:dropCrystals()
        self:fillEmpty()
        self.changes_made = true
    end
    
    return self.changes_made
end

function Game:findMatches()
    local matches = {}
    local marked = {}
    
    for y = 0, FIELD_SIZE - 1 do
        marked[y] = {}
        for x = 0, FIELD_SIZE - 1 do
            marked[y][x] = false
        end
    end
    
    for y = 0, FIELD_SIZE - 1 do
        local count = 1
        local color = self.field[y][0]
        
        for x = 1, FIELD_SIZE - 1 do
            if self.field[y][x] == color then
                count = count + 1
            else
                if count >= MIN_MATCH then
                    for i = x - count, x - 1 do
                        marked[y][i] = true
                    end
                end
                count = 1
                color = self.field[y][x]
            end
        end
        
        if count >= MIN_MATCH then
            for i = FIELD_SIZE - count, FIELD_SIZE - 1 do
                marked[y][i] = true
            end
        end
    end
    
    for x = 0, FIELD_SIZE - 1 do
        local count = 1
        local color = self.field[0][x]
        
        for y = 1, FIELD_SIZE - 1 do
            if self.field[y][x] == color then
                count = count + 1
            else
                if count >= MIN_MATCH then
                    for i = y - count, y - 1 do
                        marked[i][x] = true
                    end
                end
                count = 1
                color = self.field[y][x]
            end
        end
        
        if count >= MIN_MATCH then
            for i = FIELD_SIZE - count, FIELD_SIZE - 1 do
                marked[i][x] = true
            end
        end
    end
    
    for y = 0, FIELD_SIZE - 1 do
        for x = 0, FIELD_SIZE - 1 do
            if marked[y][x] then
                table.insert(matches, {x = x, y = y})
            end
        end
    end
    
    return matches
end

function Game:removeMatches(matches)
    for _, match in ipairs(matches) do
        self.field[match.y][match.x] = nil
        self.score = self.score + 10
    end
end

function Game:dropCrystals()
    for x = 0, FIELD_SIZE - 1 do
        local write_pos = FIELD_SIZE - 1
        
        for y = FIELD_SIZE - 1, 0, -1 do
            if self.field[y][x] ~= nil then
                if y ~= write_pos then
                    self.field[write_pos][x] = self.field[y][x]
                    self.field[y][x] = nil
                end
                write_pos = write_pos - 1
            end
        end
    end
end

function Game:fillEmpty()
    for x = 0, FIELD_SIZE - 1 do
        for y = 0, FIELD_SIZE - 1 do
            if self.field[y][x] == nil then
                self.field[y][x] = self:getRandomColor()
            end
        end
    end
end

function Game:hasPossibleMoves()
    for y = 0, FIELD_SIZE - 1 do
        for x = 0, FIELD_SIZE - 1 do
            local directions = {
                {dx = 1, dy = 0},  
                {dx = -1, dy = 0}, 
                {dx = 0, dy = 1},  
                {dx = 0, dy = -1}  
            }
            
            for _, dir in ipairs(directions) do
                local new_x = x + dir.dx
                local new_y = y + dir.dy
                
                if new_x >= 0 and new_x < FIELD_SIZE and new_y >= 0 and new_y < FIELD_SIZE then
                    local temp = self.field[y][x]
                    self.field[y][x] = self.field[new_y][new_x]
                    self.field[new_y][new_x] = temp
                    
                    local matches = self:findMatches()
                    
                    self.field[new_y][new_x] = self.field[y][x]
                    self.field[y][x] = temp
                    
                    if #matches > 0 then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

function Game:mix()
    local crystals = {}
    
    for y = 0, FIELD_SIZE - 1 do
        for x = 0, FIELD_SIZE - 1 do
            table.insert(crystals, self.field[y][x])
        end
    end
    
    for i = #crystals, 2, -1 do
        local j = math.random(i)
        crystals[i], crystals[j] = crystals[j], crystals[i]
    end
    
    local index = 1
    for y = 0, FIELD_SIZE - 1 do
        for x = 0, FIELD_SIZE - 1 do
            self.field[y][x] = crystals[index]
            index = index + 1
        end
    end
    
    self:removeInitialMatches()
end

function Game:getScore()
    return self.score
end

return Game
