-- View Module - Модуль визуализации

local View = {}
View.__index = View

function View:new()
    local instance = {}
    setmetatable(instance, self)
    return instance
end

function View:clear()
    if os.execute("cls") == nil then
        os.execute("clear")
    end
end

function View:dump(field)    
    print()
    
    io.write("   ")
    for x = 0, 9 do
        io.write(string.format("%2d", x))
    end
    print()
    
    io.write("   ")
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
    print("Controls:")
    print("  m x y d - move crystal")
    print("    x, y - coordinates (0-9)")
    print("    d - direction (l/r/u/d)")
    print("  q - quit")
    print()
end

return View
