-- Field Module - Модуль игрового поля
-- Отвечает за управление игровым полем Match-3

local GameFieldPositioning = require("src.gamefieldPositioning")
local DestructionPattern = require("src.destructionPattern")
local SpecialStones = require("src.special_stones")

local Field = {}
Field.__index = Field

local FIELD_SIZE = 10
local COLORS = {"A", "B", "C", "D", "E", "F"}
local MIN_MATCH = 3

-- Создание нового экземпляра игрового поля
function Field:new()
    local instance = {
        grid = {},
        size = FIELD_SIZE,
        positioning = GameFieldPositioning:new(FIELD_SIZE),
        destructor = DestructionPattern:new(FIELD_SIZE),
        special_stones = SpecialStones:new()
    }
    setmetatable(instance, self)
    return instance
end

-- Инициализация игрового поля
function Field:init()
    -- Генерация случайного игрового поля
    local function generateRandomGrid()
        for y = 0, self.size - 1 do
            self.grid[y] = {}
            for x = 0, self.size - 1 do
                self.grid[y][x] = COLORS[math.random(1, #COLORS)]
            end
        end
    end

    -- Удаление совпадений при генерации
    local function removeInitialMatches()
        -- Проверяет, какой цвет запрещен по горизонтали
        local function getForbiddenColorHorizontal(x, y)
            if x < MIN_MATCH - 1 then
                return nil -- недостаточно позиций слева для образования совпадения
            end
            
            -- Проверяем последние MIN_MATCH-1 позиций слева
            local prev_color = self.grid[y][x - 1]
            if not prev_color then
                return nil
            end
            
            local count = 1
            for i = x - 2, math.max(0, x - MIN_MATCH + 1), -1 do
                if self.grid[y][i] == prev_color then
                    count = count + 1
                else
                    break
                end
            end
            
            -- Если уже есть MIN_MATCH-1 одинаковых цветов слева, этот цвет запрещен
            if count >= MIN_MATCH - 1 then
                return prev_color
            end
            
            return nil
        end

        -- Проверяет, какой цвет запрещен по вертикали
        local function getForbiddenColorVertical(x, y)
            if y < MIN_MATCH - 1 then
                return nil -- недостаточно позиций сверху для образования совпадения
            end
            
            -- Проверяем последние MIN_MATCH-1 позиций сверху
            local prev_color = self.grid[y - 1][x]
            if not prev_color then
                return nil
            end
            
            local count = 1
            for i = y - 2, math.max(0, y - MIN_MATCH + 1), -1 do
                if self.grid[i][x] == prev_color then
                    count = count + 1
                else
                    break
                end
            end
            
            -- Если уже есть MIN_MATCH-1 одинаковых цветов сверху, этот цвет запрещен
            if count >= MIN_MATCH - 1 then
                return prev_color
            end
            
            return nil
        end

        for y = 0, self.size - 1 do
            for x = 0, self.size - 1 do
                local forbidden_colors = {}
                
                local horizontal_forbidden = getForbiddenColorHorizontal(x, y)
                if horizontal_forbidden then
                    forbidden_colors[horizontal_forbidden] = true
                end
                
                local vertical_forbidden = getForbiddenColorVertical(x, y)
                if vertical_forbidden then
                    forbidden_colors[vertical_forbidden] = true
                end
                
                local current_color = self.grid[y][x]
                if forbidden_colors[current_color] then
                    local new_color
                    repeat
                        new_color = COLORS[math.random(#COLORS)]
                    until not forbidden_colors[new_color]
                    
                    self.grid[y][x] = new_color
                end
            end
        end
    end

    self.grid = {}
    generateRandomGrid()
    removeInitialMatches()
end

-- Получить текущее состояние игрового поля
function Field:getGrid()
    return self.grid
end

-- Получить размер игрового поля
function Field:getSize()
    return self.size
end

-- Поиск совпадений (ряда кристаллов 3 и больше)
function Field:findMatches()
    local matches = {}
    local marked = {}
    
    for y = 0, self.size - 1 do
        marked[y] = {}
        for x = 0, self.size - 1 do
            marked[y][x] = false
        end
    end
    
    for y = 0, self.size - 1 do
        local count = 1
        local color = self.grid[y][0]
        
        for x = 1, self.size - 1 do
            if self.grid[y][x] == color then
                count = count + 1
            else
                if count >= MIN_MATCH then
                    for i = x - count, x - 1 do
                        marked[y][i] = true
                    end
                end
                count = 1
                color = self.grid[y][x]
            end
        end
        
        if count >= MIN_MATCH then
            for i = self.size - count, self.size - 1 do
                marked[y][i] = true
            end
        end
    end
    
    for x = 0, self.size - 1 do
        local count = 1
        local color = self.grid[0][x]
        
        for y = 1, self.size - 1 do
            if self.grid[y][x] == color then
                count = count + 1
            else
                if count >= MIN_MATCH then
                    for i = y - count, y - 1 do
                        marked[i][x] = true
                    end
                end
                count = 1
                color = self.grid[y][x]
            end
        end
        
        if count >= MIN_MATCH then
            for i = self.size - count, self.size - 1 do
                marked[i][x] = true
            end
        end
    end
    
    for y = 0, self.size - 1 do
        for x = 0, self.size - 1 do
            if marked[y][x] then
                table.insert(matches, {x = x, y = y})
            end
        end
    end
    
    return matches
end

-- Удаление совпадений, падение и заполнение новых кристаллов
function Field:removeMatches(matches)
    local function removeCrystals(positions)
        for _, pos in ipairs(positions) do
            self.grid[pos.y][pos.x] = nil
        end
    end

    local function dropCrystals()
        for x = 0, self.size - 1 do
            local write_pos = self.size - 1
            
            for y = self.size - 1, 0, -1 do
                if self.grid[y][x] ~= nil then
                    if y ~= write_pos then
                        self.grid[write_pos][x] = self.grid[y][x]
                        self.grid[y][x] = nil
                    end
                    write_pos = write_pos - 1
                end
            end
        end
    end

    local function fillEmpty()
        for x = 0, self.size - 1 do
            for y = 0, self.size - 1 do
                if self.grid[y][x] == nil then
                    self.grid[y][x] = COLORS[math.random(1, #COLORS)]
                end
            end
        end
    end

    removeCrystals(matches)
    dropCrystals()
    fillEmpty()
end

-- Перемещение кристаллов (если возможно и дает совпадение)
function Field:move(from, to)
    local function swapCrystals(x1, y1, x2, y2)
        if self.positioning:isValidPosition(x1, y1) and self.positioning:isValidPosition(x2, y2) then
            local temp = self.grid[y1][x1]
            self.grid[y1][x1] = self.grid[y2][x2]
            self.grid[y2][x2] = temp
            return true
        end

        return false
    end

    local from_x, from_y = from.x, from.y
    local to_x, to_y = to.x, to.y
    
    if not swapCrystals(from_x, from_y, to_x, to_y) then
        return false
    end

    local matches = self:findMatches()
    
    if #matches > 0 then
        return true
    end

    swapCrystals(from_x, from_y, to_x, to_y)
    return false
end

-- Проверяет наличие возможных ходов
function Field:hasPossibleMoves()
    -- Проверяет горизонтальные паттерны "2 из 3"
    local function getHorizontalPattern(position)
        local x, y = position.x, position.y
        
        if x > self.size - 3 then
            return nil 
        end
        
        local colors = {
            self.grid[y][x],
            self.grid[y][x + 1], 
            self.grid[y][x + 2]
        }
        
        if colors[1] == colors[2] and colors[1] ~= colors[3] then
            return {
                color = colors[1],
                pattern_pos = 3,
                field_x = x + 2,
                field_y = y
            }
        elseif colors[1] == colors[3] and colors[1] ~= colors[2] then
            return {
                color = colors[1],
                pattern_pos = 2,
                field_x = x + 1,
                field_y = y
            }
        elseif colors[2] == colors[3] and colors[2] ~= colors[1] then
            return {
                color = colors[2],
                pattern_pos = 1,
                field_x = x,
                field_y = y
            }
        end
        
        return nil
    end

    -- Проверяет вертикальные паттерны "2 из 3"
    local function getVerticalPattern(position)
        local x, y = position.x, position.y
        
        if y > self.size - 3 then
            return nil 
        end
        
        local colors = {
            self.grid[y][x],
            self.grid[y + 1][x], 
            self.grid[y + 2][x]
        }
        
        if colors[1] == colors[2] and colors[1] ~= colors[3] then
            return {
                color = colors[1],
                pattern_pos = 3,
                field_x = x,
                field_y = y + 2
            }
        elseif colors[1] == colors[3] and colors[1] ~= colors[2] then
            return {
                color = colors[1],
                pattern_pos = 2,
                field_x = x,
                field_y = y + 1
            }
        elseif colors[2] == colors[3] and colors[2] ~= colors[1] then
            return {
                color = colors[2],
                pattern_pos = 1,
                field_x = x,
                field_y = y
            }
        end
        
        return nil
    end

    -- Ищет количество кристаллов нужного цвета рядом с позицией
    local function countAdjacentCrystals(x, y, color)
        local count = 0
        local adjacent_positions = {
            {x = x - 1, y = y},     
            {x = x + 1, y = y},     
            {x = x, y = y - 1},    
            {x = x, y = y + 1}     
        }
        
        for _, pos in ipairs(adjacent_positions) do
            if self.positioning:isValidPosition(pos.x, pos.y) and self.grid[pos.y][pos.x] == color then
                count = count + 1
            end
        end
        
        return count
    end
    
    for y = 0, self.size - 1 do
        for x = 0, self.size - 3 do
            local pattern = getHorizontalPattern({x = x, y = y})
            if pattern then
                local required_count
                
                if pattern.pattern_pos == 1 or pattern.pattern_pos == 3 then
                    required_count = 2 
                else
                    required_count = 3
                end
                
                local available_count = countAdjacentCrystals(pattern.field_x, pattern.field_y, pattern.color)
                
                if available_count >= required_count then
                    return true
                end
            end
        end
    end
    
    for x = 0, self.size - 1 do
        for y = 0, self.size - 3 do
            local pattern = getVerticalPattern({x = x, y = y})
            if pattern then
                local required_count
                
                if pattern.pattern_pos == 1 or pattern.pattern_pos == 3 then
                    required_count = 2
                else
                    required_count = 3
                end
                
                local available_count = countAdjacentCrystals(pattern.field_x, pattern.field_y, pattern.color)
                
                if available_count >= required_count then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Общая функция уничтожения по паттерну (на данный момент не требуется)
-- Возвращает список позиций для уничтожения
function Field:destroy(pattern, context)
    local full_context = context or {}
    if not full_context.field_grid then
        full_context.field_grid = self.grid
    end
    
    local positions = self.destructor:getPositions(pattern, full_context)
    
    self:removeMatches(positions)
    
    return positions
end

-- Обрабатывает один цикл поиска и удаления совпадений
-- Возвращает true, если были найдены и удалены совпадения
function Field:processMatches()
    local matches = self:findMatches()
    if #matches > 0 then
        self:removeMatches(matches)
        return true
    end
    return false
end

return Field
