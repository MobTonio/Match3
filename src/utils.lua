-- Utility functions for Match-3 Game
local utils = {}

math.randomseed(os.time())

function utils.randomRange(min, max)
    return math.random(min, max)
end

function utils.shuffleArray(array)
    local n = #array
    for i = n, 2, -1 do
        local j = math.random(i)
        array[i], array[j] = array[j], array[i]
    end
    return array
end

function utils.deepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in pairs(original) do
            copy[utils.deepCopy(key)] = utils.deepCopy(value)
        end
        setmetatable(copy, utils.deepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

function utils.isValidPosition(x, y, field_size)
    field_size = field_size or 10
    return x >= 0 and x < field_size and y >= 0 and y < field_size
end

function utils.clearScreen()
    local success = os.execute("cls")
    if not success then
        os.execute("clear")
    end
end

-- Форматирование времени
function utils.formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

function utils.isEmpty(str)
    return str == nil or str:match("^%s*$") ~= nil
end

function utils.trim(str)
    return str:match("^%s*(.-)%s*$")
end

function utils.split(str, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter or "%s")
    
    for match in str:gmatch(pattern) do
        table.insert(result, match)
    end
    
    return result
end

function utils.contains(array, element)
    for _, value in ipairs(array) do
        if value == element then
            return true
        end
    end
    return false
end

function utils.tableSize(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function utils.directionToCoords(direction)
    local directions = {
        l = {dx = -1, dy = 0},  
        r = {dx = 1, dy = 0},   
        u = {dx = 0, dy = -1},  
        d = {dx = 0, dy = 1}    
    }
    
    return directions[direction:lower()]
end

function utils.validateMoveCommand(input)
    local command, x, y, direction = input:match("(%w+)%s+(%d+)%s+(%d+)%s+(%w)")
    
    if not command or command:lower() ~= "m" then
        return false, "Неверная команда. Используйте 'm'"
    end
    
    x, y = tonumber(x), tonumber(y)
    if not x or not y or x < 0 or x > 9 or y < 0 or y > 9 then
        return false, "Координаты должны быть от 0 до 9"
    end
    
    direction = direction:lower()
    if not utils.contains({"l", "r", "u", "d"}, direction) then
        return false, "Направление должно быть l, r, u или d"
    end
    
    return true, {x = x, y = y, direction = direction}
end

function utils.createMatrix(width, height, default_value)
    local matrix = {}
    default_value = default_value or nil
    
    for y = 0, height - 1 do
        matrix[y] = {}
        for x = 0, width - 1 do
            matrix[y][x] = default_value
        end
    end
    
    return matrix
end

return utils
