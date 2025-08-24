-- Field Module - Модуль игрового поля
-- Отвечает за управление игровым полем Match-3

local GameFieldPositioning = require("src.gamefieldPositioning")
local DestructionPattern = require("src.destructionPattern")

local Field = {}
Field.__index = Field

local FIELD_SIZE = 10
local COLORS = {"A", "B", "C", "D", "E", "F"}
local MIN_MATCH = 3

function Field:new()
    local instance = {
        grid = {},
        size = FIELD_SIZE,
        positioning = GameFieldPositioning:new(FIELD_SIZE),
        destructor = DestructionPattern:new(FIELD_SIZE)
    }
    setmetatable(instance, self)
    return instance
end

function Field:init()
    self.grid = {}
    self:generateRandomGrid()
    self:removeInitialMatches()
end

function Field:generateRandomGrid()
    for y = 0, self.size - 1 do
        self.grid[y] = {}
        for x = 0, self.size - 1 do
            self.grid[y][x] = self:getRandomColor()
        end
    end
end

function Field:getRandomColor()
    return COLORS[math.random(1, #COLORS)]
end

function Field:removeInitialMatches()
    for y = 0, self.size - 1 do
        for x = 0, self.size - 1 do
            local forbidden_colors = {}
            
            -- Проверяем горизонтально назад (влево)
            local horizontal_forbidden = self:getForbiddenColorHorizontal(x, y)
            if horizontal_forbidden then
                forbidden_colors[horizontal_forbidden] = true
            end
            
            -- Проверяем вертикально назад (вверх)
            local vertical_forbidden = self:getForbiddenColorVertical(x, y)
            if vertical_forbidden then
                forbidden_colors[vertical_forbidden] = true
            end
            
            -- Если текущий цвет запрещен, меняем его
            local current_color = self.grid[y][x]
            if forbidden_colors[current_color] then
                -- Ищем разрешенный цвет
                for _, color in ipairs(COLORS) do
                    if not forbidden_colors[color] then
                        self.grid[y][x] = color
                        break
                    end
                end
            end
        end
    end
end

-- Проверяет, какой цвет запрещен по горизонтали (проверка назад)
function Field:getForbiddenColorHorizontal(x, y)
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

-- Проверяет, какой цвет запрещен по вертикали (проверка назад)
function Field:getForbiddenColorVertical(x, y)
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

function Field:getGrid()
    return self.grid
end

function Field:getSize()
    return self.size
end

function Field:swapCrystals(x1, y1, x2, y2)
    if self:isValidPosition(x1, y1) and self:isValidPosition(x2, y2) then
        local temp = self.grid[y1][x1]
        self.grid[y1][x1] = self.grid[y2][x2]
        self.grid[y2][x2] = temp
        return true
    end
    return false
end

function Field:isValidPosition(x, y)
    return x >= 0 and x < self.size and y >= 0 and y < self.size
end

function Field:findMatches()
    local matches = {}
    local marked = {}
    
    for y = 0, self.size - 1 do
        marked[y] = {}
        for x = 0, self.size - 1 do
            marked[y][x] = false
        end
    end
    
    -- Поиск горизонтальных совпадений
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
    
    -- Поиск вертикальных совпадений
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
    
    -- Собираем все найденные совпадения
    for y = 0, self.size - 1 do
        for x = 0, self.size - 1 do
            if marked[y][x] then
                table.insert(matches, {x = x, y = y})
            end
        end
    end
    
    return matches
end

function Field:removeCrystals(positions)
    for _, pos in ipairs(positions) do
        self.grid[pos.y][pos.x] = nil
    end
end

function Field:dropCrystals()
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

function Field:fillEmpty()
    for x = 0, self.size - 1 do
        for y = 0, self.size - 1 do
            if self.grid[y][x] == nil then
                self.grid[y][x] = self:getRandomColor()
            end
        end
    end
end

function Field:canMakeMove(from, to)
    local from_x, from_y = from.x, from.y
    local to_x, to_y = to.x, to.y
    
    -- Временно выполняем обмен
    self:swapCrystals(from_x, from_y, to_x, to_y)

    -- Проверяем, есть ли совпадения
    local matches = self:findMatches()
    
    -- Отменяем обмен
    self:swapCrystals(from_x, from_y, to_x, to_y)
    
    return #matches > 0
end

function Field:hasPossibleMoves()
    for y = 0, self.size - 1 do
        for x = 0, self.size - 1 do
            local from = {x = x, y = y}
            
            -- Проверяем все 4 направления
            local directions = {
                {x = x - 1, y = y},     -- влево
                {x = x + 1, y = y},     -- вправо
                {x = x, y = y - 1},     -- вверх
                {x = x, y = y + 1}      -- вниз
            }
            
            for _, to in ipairs(directions) do
                -- Проверяем, что целевая позиция валидна
                if self:isValidPosition(to.x, to.y) then
                    if self:canMakeMove(from, to) then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- Общая функция уничтожения по паттерну (на данный момент не требуется)
function Field:destroy(pattern, context)
    -- Дополняем контекст данными о поле, если они нужны
    local full_context = context or {}
    if not full_context.field_grid then
        full_context.field_grid = self.grid
    end
    
    -- Получаем позиции для уничтожения через модуль паттернов
    local positions = self.destructor:getPositions(pattern, full_context)
    
    -- Выполняем уничтожение
    self:removeCrystals(positions)
    
    return positions
end

-- Обрабатывает один цикл поиска и удаления совпадений
function Field:processMatches()
    local matches = self:findMatches()
    if #matches > 0 then
        self:removeCrystals(matches)
        self:dropCrystals()
        self:fillEmpty()
        return true -- произошли изменения
    end
    return false -- изменений не было
end

return Field
