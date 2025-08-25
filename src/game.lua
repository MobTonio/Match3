-- Game Model - Модель игры Match-3
-- Реализует логику игры с использованием ООП

local Field = require("src.field")
local View = require("src.view")

local Game = {}
Game.__index = Game

-- Инициализация игры
function Game:init()
    local instance = {
        field = Field:new(),
        view = View:new(),
        changes_made = false
    }
    setmetatable(instance, self)

    instance.field:init()
    instance.view:dump(instance.field:getGrid())
    
    return instance
end

-- Перемещение кристалла
function Game:move(from, to)    
    return self.field:move(from, to)
end

-- Обработка изменений на поле
function Game:tick()
    self.changes_made = self.field:processMatches()
    
    if not self.field:hasPossibleMoves() then
        self:mix()
    end

    return self.changes_made
end

-- Перемешивание кристаллов
function Game:mix()
    self.field:init()
    self.view:dump(self.field:getGrid())
end

-- Вывод текущего состояния игры
function Game:dump()
    self.view:dump(self.field:getGrid())
end

return Game
