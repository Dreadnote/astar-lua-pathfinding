-- visualization.lua (упрощенная версия для Windows)
-- Управление визуализацией: цвета, отрисовка, меню

local Visualization = {}

-- ANSI цветовые коды
Visualization.colors = {
    reset = "\27[0m",
    
    -- Основные цвета
    black = "\27[30m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m",
    magenta = "\27[35m",
    cyan = "\27[36m",
    white = "\27[37m",
    gray = "\27[90m",
    
    -- Яркие цвета
    bright_red = "\27[91m",
    bright_green = "\27[92m",
    bright_yellow = "\27[93m",
    bright_blue = "\27[94m",
    bright_magenta = "\27[95m",
    bright_cyan = "\27[96m",
    bright_white = "\27[97m",
    
    -- Фоны
    bg_black = "\27[40m",
    bg_red = "\27[41m",
    bg_green = "\27[42m",
    bg_yellow = "\27[43m",
    bg_blue = "\27[44m",
    bg_magenta = "\27[45m",
    bg_cyan = "\27[46m",
    bg_white = "\27[47m",
    
    -- Стили
    bold = "\27[1m",
    dim = "\27[2m",
    underline = "\27[4m",
}

---Очищает экран
function Visualization.clear_screen()
    os.execute("cls")
end

---Устанавливает цвет текста
---@param color string
function Visualization.set_color(color)
    io.write(Visualization.colors[color] or "")
end

---Сбрасывает все цвета и стили
function Visualization.reset_color()
    io.write(Visualization.colors.reset)
end

---Рисует горизонтальную линию
---@param width number
---@param char string
function Visualization.draw_line(width, char)
    io.write(string.rep(char, width))
end

---Рисует рамку с заголовком
---@param title string
---@param width number
function Visualization.draw_header(title, width)
    Visualization.set_color("bright_cyan")
    Visualization.draw_line(width, "=")
    io.write("\n")
    Visualization.set_color("bright_white")
    io.write(" " .. title .. "\n")
    Visualization.set_color("bright_cyan")
    Visualization.draw_line(width, "=")
    Visualization.reset_color()
    io.write("\n")
end

---Рисует информационную панель
---@param text table
---@param width number
function Visualization.draw_info_panel(text, width)
    Visualization.set_color("cyan")
    io.write("+" .. string.rep("-", width - 2) .. "+\n")
    
    for _, line in ipairs(text) do
        io.write("| " .. line .. string.rep(" ", width - #line - 3) .. "|\n")
    end
    
    io.write("+" .. string.rep("-", width - 2) .. "+")
    Visualization.reset_color()
    io.write("\n")
end

---Рисует сетку с цветами и числами
---@param grid Grid
---@param state table
---@param mode string
---@param start_x number
---@param start_y number
---@param goal_x number
---@param goal_y number
function Visualization.draw_grid(grid, state, mode, start_x, start_y, goal_x, goal_y)
    local current = state.current_node
    local open_list = state.open_list or {}
    local closed_list = state.closed_list or {}
    
    -- Создаем карту значений
    local values = {}
    for y = 1, grid.height do
        values[y] = {}
        for x = 1, grid.width do
            values[y][x] = nil
        end
    end
    
    -- Заполняем значения
    for _, node in ipairs(open_list) do
        if mode == "g" then
            values[node.y][node.x] = {value = node.g, type = "open"}
        elseif mode == "h" then
            values[node.y][node.x] = {value = node.h, type = "open"}
        elseif mode == "f" then
            values[node.y][node.x] = {value = node.f, type = "open"}
        end
    end
    
    for _, node in ipairs(closed_list) do
        if mode == "g" then
            values[node.y][node.x] = {value = node.g, type = "closed"}
        elseif mode == "h" then
            values[node.y][node.x] = {value = node.h, type = "closed"}
        elseif mode == "f" then
            values[node.y][node.x] = {value = node.f, type = "closed"}
        end
    end
    
    -- Заголовок с координатами X
    io.write("   ")
    for x = 1, grid.width do
        Visualization.set_color("gray")
        io.write(string.format("%3d ", x))
    end
    Visualization.reset_color()
    io.write("\n")
    
    -- Разделитель
    io.write("   ")
    Visualization.set_color("gray")
    for x = 1, grid.width do
        io.write("--- ")
    end
    Visualization.reset_color()
    io.write("\n")
    
    -- Отрисовка
    for y = 1, grid.height do
        Visualization.set_color("gray")
        io.write(string.format("%2d |", y))
        Visualization.reset_color()
        
        for x = 1, grid.width do
            io.write(" ")
            
            if grid.cells[y][x] == 1 then
                -- Стена
                Visualization.set_color("bright_black")
                io.write("###")
                Visualization.reset_color()
            elseif x == start_x and y == start_y then
                -- Старт
                Visualization.set_color("bg_green")
                Visualization.set_color("black")
                io.write(" @ ")
                Visualization.reset_color()
            elseif x == goal_x and y == goal_y then
                -- Цель
                Visualization.set_color("bg_red")
                Visualization.set_color("white")
                io.write(" X ")
                Visualization.reset_color()
            elseif current and x == current.x and y == current.y then
                -- Текущий узел
                Visualization.set_color("bg_yellow")
                Visualization.set_color("black")
                local val = values[y][x]
                if mode ~= "simple" and val then
                    io.write(string.format("%3d", val.value))
                else
                    io.write(" * ")
                end
                Visualization.reset_color()
            elseif values[y][x] and values[y][x].type == "open" then
                -- Открытый узел
                Visualization.set_color("bg_cyan")
                Visualization.set_color("black")
                io.write(string.format("%3d", values[y][x].value))
                Visualization.reset_color()
            elseif values[y][x] and values[y][x].type == "closed" then
                -- Закрытый узел
                Visualization.set_color("bg_blue")
                Visualization.set_color("white")
                io.write(string.format("%3d", values[y][x].value))
                Visualization.reset_color()
            else
                -- Пустая клетка
                Visualization.set_color("dim")
                io.write(" . ")
                Visualization.reset_color()
            end
            
            io.write(" ")
        end
        io.write("\n")
    end
end

---Рисует информацию о соседях
---@param neighbors_info table
function Visualization.draw_neighbors_info(neighbors_info)
    if not neighbors_info or #neighbors_info == 0 then
        return
    end
    
    Visualization.set_color("bright_cyan")
    io.write("+-----------------------------------------------------------------------------+\n")
    io.write("| Neighbors of current node:                                                 |\n")
    io.write("+-----------------------------------------------------------------------------+\n")
    Visualization.reset_color()
    
    for _, n in ipairs(neighbors_info) do
        local status_icon = ""
        local status_color = ""
        
        if n.status == "closed" then
            status_icon = "[CLOSED]"
            status_color = "gray"
        elseif n.status == "in_open" then
            status_icon = "[IN OPEN worse]"
            status_color = "yellow"
        elseif n.status == "in_open_better" then
            status_icon = "[IN OPEN better!]"
            status_color = "green"
        else
            status_icon = "[NEW]"
            status_color = "bright_green"
        end
        
        Visualization.set_color(status_color)
        io.write(string.format("|    (%d,%d) -> G=%2d H=%2d F=%2d  %-20s", 
              n.x, n.y, n.g, n.h, n.f, status_icon))
        Visualization.reset_color()
        
        if n.existing_g then
            Visualization.set_color("gray")
            io.write(string.format("  (existing G=%d)", n.existing_g))
            Visualization.reset_color()
        end
        io.write("\n")
    end
    
    Visualization.set_color("bright_cyan")
    io.write("+-----------------------------------------------------------------------------+\n")
    Visualization.reset_color()
end

---Рисует Open List
---@param open_list table
---@param best_node table
function Visualization.draw_open_list(open_list, best_node)
    if #open_list == 0 then
        return
    end
    
    Visualization.set_color("bright_green")
    io.write("+-----------------------------------------------------------------------------+\n")
    io.write("| Open list (sorted by F-cost):                                               |\n")
    io.write("+-----------------------------------------------------------------------------+\n")
    Visualization.reset_color()
    
    for i, node in ipairs(open_list) do
        local marker = ""
        if best_node and node.x == best_node.x and node.y == best_node.y then
            marker = "  <-- BEST"
            Visualization.set_color("bright_green")
        else
            Visualization.set_color("white")
        end
        
        io.write(string.format("|    %2d. (%d,%d) -> G=%2d H=%2d F=%2d%s\n", 
              i, node.x, node.y, node.g, node.h, node.f, marker))
        Visualization.reset_color()
    end
    
    Visualization.set_color("bright_green")
    io.write("+-----------------------------------------------------------------------------+\n")
    Visualization.reset_color()
end

---Рисует статистику
---@param step_count number
---@param open_count number
---@param closed_count number
function Visualization.draw_stats(step_count, open_count, closed_count)
    Visualization.set_color("bright_magenta")
    io.write("+-----------------------------------------------------------------------------+\n")
    io.write(string.format("| Step: %d | Open nodes: %d | Closed nodes: %d", 
          step_count, open_count, closed_count))
    io.write(string.rep(" ", 73 - #tostring(step_count) - #tostring(open_count) - #tostring(closed_count)) .. "|\n")
    io.write("+-----------------------------------------------------------------------------+\n")
    Visualization.reset_color()
end

---Рисует меню управления
---@param mode string
function Visualization.draw_menu(mode)
    local mode_display = ""
    if mode == "simple" then mode_display = "SIMPLE"
    elseif mode == "g" then mode_display = "G-COST"
    elseif mode == "h" then mode_display = "H-COST"
    elseif mode == "f" then mode_display = "F-COST"
    end
    
    Visualization.set_color("bright_yellow")
    io.write("+-----------------------------------------------------------------------------+\n")
    io.write("|  Controls: [Enter] next step | [G] G-cost | [H] H-cost | [F] F-cost        |\n")
    io.write("|            [S] Simple mode | [Q] Quit                                       |\n")
    io.write("|                                                                             |\n")
    io.write(string.format("|  Current mode: %-49s|\n", mode_display))
    io.write("+-----------------------------------------------------------------------------+\n")
    Visualization.reset_color()
    io.write("\n")
end

return Visualization