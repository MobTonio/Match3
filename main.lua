-- Match-3 Game - Main Entry Point
local Game = require("src.game")
local CommandParser = require("src.commandParser")

-- Обработка пользовательского ввода
local function processInput(input)
    local parser = CommandParser:new()
    local command = parser:parseCommand(input)

    if command.type == "quit" then
        return {type = "quit"}
    elseif command.type == "move" then
        return {
            type = "move",
            from = command.from,
            to = command.to
        }
    elseif command.type == "error" then
        print(command.message)
        return {type = "continue"}
    end
    
    return {type = "continue"}
end

local function main()
    local game = Game:init()
    
    while true do
        print("Input command:")
        local input = io.read()
        
        local result = processInput(input)

        if result.type == "quit" then
            print("Exiting the game...")
            break
        elseif result.type == "move" then
            local success = game:move(result.from, result.to)
            if not success then
                print("Invalid move!")
            end
        end
        
        while game:tick() do
            print("Processing...")
            game:dump()
        end
        
        print()
    end
end

main()
