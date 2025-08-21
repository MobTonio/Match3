-- View Module - Модуль визуализации

local View = {}
View.__index = View

function View:new()
    local instance = {}
    setmetatable(instance, self)
    return instance
end

function View:dump(field)
    if os.execute("cls") == nil then
        os.execute("clear")
    end
    
    print("=== Match-3 Game ===")
    print()
    
    io.write("  ")
    for x = 0, 9 do
        io.write(string.format("%2d", x))
    end
    print()
    
    io.write("  ")
    for x = 0, 9 do
        io.write(" -")
    end
    print()
    
    for y = 0, 9 do
        io.write(string.format("%d |", y))
        
        for x = 0, 9 do
            local crystal = field[y][x]
            if crystal then
                io.write(string.format(" %s", crystal))
            else
                io.write("  ")
            end
        end
        
        print()
    end
    
    print()
end

function View:showInstructions()
    print("Управление:")
    print("  m x y d - переместить кристалл")
    print("    x, y - координаты (0-9)")
    print("    d - направление (l/r/u/d)")
    print("  q - выход")
    print()
end

function View:showMessage(message)
    print(">>> " .. message)
end

function View:showScore(score)
    print("Счет: " .. score)
    print()
end

return View
