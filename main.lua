-- Match-3 Game - Main Entry Point

local Game = require("src.game")
local View = require("src.view")

local function main()
    print("=== Match-3 Game ===")
    print("Controlls: m x y d (x,y coordinates 0-9, d direction l/r/u/d)")
    print("Exit: q")
    print()
    
    local game = Game:new()
    local view = View:new()
    
    game:init()
    
    while true do
        view:dump(game:getField())
        
        while game:tick() do
            print("Processing...")
            view:dump(game:getField())
        end
        
        if not game:hasPossibleMoves() then
            print("No possible moves. Shuffling the board...")
            game:mix()
            view:dump(game:getField())
        end
        
        print("Input command:")
        local input = io.read()
        
        if input == "q" then
            print("Exiting the game...")
            break
        end
        
        local command, x, y, direction = input:match("(%w+)%s+(%d+)%s+(%d+)%s+(%w)")
        
        if command == "m" and x and y and direction then
            x, y = tonumber(x), tonumber(y)
            if x >= 0 and x <= 9 and y >= 0 and y <= 9 then
                local success = game:move(x, y, direction)
                if not success then
                    print("Invalid move!")
                end
            else
                print("Coordinates must be between 0 and 9!")
            end
        else
            print("Invalid command! Use: m x y d or q")
        end
        
        print()
    end
end

main()
