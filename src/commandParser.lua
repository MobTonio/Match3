-- Command Parser Module - Модуль парсинга команд
-- Отвечает за разбор пользовательского ввода

local GameFieldPositioning = require("src.gamefieldPositioning")

local CommandParser = {}
CommandParser.__index = CommandParser

function CommandParser:new()
    local instance = {
        positioning = GameFieldPositioning:new(10)
    }
    setmetatable(instance, self)
    return instance
end

-- Парсит команду и возвращает from, to координаты или nil при ошибке
function CommandParser:parseCommand(input)
    if input == "q" then
        return {type = "quit"}
    end
    
    local command, x, y, direction = input:match("(%w+)%s+(%d+)%s+(%d+)%s+(%w)")
    
    if command == "m" and x and y and direction then
        x, y = tonumber(x), tonumber(y)
        
        -- Используем GameFieldPositioning для валидации и преобразования
        local from = {x = x, y = y}
        local to = self.positioning:directionToCoordinates(from, direction)
        
        if to then
            return {
                type = "move",
                from = from,
                to = to
            }
        else
            return {type = "error", message = "Invalid direction or move out of bounds!"}
        end
    else
        return {type = "error", message = "Invalid command! Use: m x y d or q"}
    end
end

return CommandParser
