-- Game Model - Модель игры Match-3
-- Реализует логику игры с использованием ООП

local Field = require("src.field")
local View = require("src.view")

local Game = {}
Game.__index = Game

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

function Game:move(from, to)
    local from_x, from_y = from.x, from.y
    local to_x, to_y = to.x, to.y
    
    -- Проверяем, что координаты валидны
    if not self.field:isValidPosition(from_x, from_y) or not self.field:isValidPosition(to_x, to_y) then
        return false
    end

    if not self.field:canMakeMove(from, to) then
        return false
    end

    self.field:swapCrystals(from_x, from_y, to_x, to_y)
    return true
end

function Game:tick()
    self.changes_made = self.field:processMatches()
    
    if not self.field:hasPossibleMoves() then
        self:mix()
    end

    return self.changes_made
end

function Game:mix()
    self.field:init()
    self.view:dump(self.field:getGrid())
end

function Game:dump()
    self.view:dump(self.field:getGrid())
end

return Game
