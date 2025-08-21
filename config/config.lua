-- Configuration file for Match-3 Game
local config = {
    -- Игровые настройки
    game = {
        field_size = 10,
        min_match = 3,
        colors = {"A", "B", "C", "D", "E", "F"},
        points_per_crystal = 10
    },
    
    -- Настройки отображения
    display = {
        clear_screen = true,
        show_score = true,
        show_instructions = true
    },
    
    -- Настройки приложения
    app = {
        name = "Match-3 Game",
        version = "1.0.0",
        debug = false
    },
    
    -- Пути к модулям
    paths = {
        src = "src/",
        config = "config/"
    },
    
    -- Специальные камни (для будущего расширения)
    special_stones = {
        enabled = false,
        types = {
            bomb = {symbol = "*", effect = "destroy_area"},
            line_horizontal = {symbol = "-", effect = "destroy_row"},
            line_vertical = {symbol = "|", effect = "destroy_column"},
            rainbow = {symbol = "@", effect = "destroy_color"}
        }
    }
}

return config
