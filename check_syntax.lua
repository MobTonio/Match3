-- Скрипт для проверки синтаксиса всех модулей
-- Запускается без Lua интерпретатора для проверки структуры

print("=== Проверка синтаксиса модулей Match-3 Game ===")
print()

local files = {
    "src/game.lua",
    "src/view.lua", 
    "src/special_stones.lua",
    "config/config.lua"
}

local function checkFile(filename)
    local file = io.open(filename, "r")
    if not file then
        print("❌ " .. filename .. " - файл не найден")
        return false
    end
    
    local content = file:read("*a")
    file:close()
    
    local func, err = load(content, filename)
    if func then
        print("✅ " .. filename .. " - синтаксис корректен")
        return true
    else
        print("❌ " .. filename .. " - ошибка синтаксиса: " .. err)
        return false
    end
end

print("Проверка файлов:")
local all_ok = true

for _, filename in ipairs(files) do
    if not checkFile(filename) then
        all_ok = false
    end
end

print()
if all_ok then
    print("Все файлы прошли проверку синтаксиса!")
    print("Для запуска игры установите Lua и выполните: lua main.lua")
    print("Инструкции по установке см. в файле INSTALL.md")
else
    print("Обнаружены ошибки в файлах. Проверьте синтаксис.")
end
