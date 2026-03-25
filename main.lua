-- main.lua
-- A* Pathfinding с пошаговой визуализацией

package.path = "./?.lua;" .. package.path

local Grid = require("grid")
local AStarStepped = require("astar_stepped")
local Viz = require("visualization")

-- Лабиринт (0 - проходимо, 1 - стена)
local maze_data = {
    {0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 1, 1, 1, 0, 1, 0},
    {0, 1, 0, 0, 0, 0, 1, 0},
    {1, 1, 0, 1, 1, 1, 1, 0},
    {0, 0, 0, 1, 0, 0, 0, 0},
    {0, 1, 1, 1, 0, 1, 1, 0},
    {0, 0, 0, 0, 0, 0, 0, 0}
}

local grid = Grid.new(maze_data)

-- Функция для ввода координат
local function get_coordinates(prompt)
    print(prompt)
    io.write("X: ")
    local x = tonumber(io.read())
    io.write("Y: ")
    local y = tonumber(io.read())
    return x, y
end

-- Функция для проверки корректности координат
local function is_valid_coordinate(x, y, grid)
    if not x or not y then
        print("Error: please enter numbers!")
        return false
    end
    
    if x < 1 or x > grid.width or y < 1 or y > grid.height then
        print(string.format("Error: coordinates must be from 1 to %d for X and from 1 to %d for Y", 
              grid.width, grid.height))
        return false
    end
    
    if not grid:is_walkable(x, y) then
        print("Error: this cell is a wall!")
        return false
    end
    
    return true
end

-- Функция для чтения клавиши (Enter, G, H, F, S, Q)
local function read_key()
    local key = io.read()
    if key == "" then
        return "enter"
    end
    key = key:lower()
    if key == "g" then return "g"
    elseif key == "h" then return "h"
    elseif key == "f" then return "f"
    elseif key == "s" then return "s"
    elseif key == "q" then return "q"
    else return nil
    end
end

-- Функция для безопасного получения информации о соседях
local function get_safe_neighbors_info(solver)
    if solver and solver.get_neighbors_info then
        local success, result = pcall(function()
            return solver:get_neighbors_info()
        end)
        if success then
            return result
        end
    end
    return {}
end

-- Основная программа
Viz.clear_screen()
print("=== A* Pathfinding Algorithm with Step-by-Step Visualization ===\n")

-- Показываем простую версию лабиринта
print("Maze layout (. = empty, # = wall):")
for y = 1, grid.height do
    io.write(string.format("%2d ", y))
    for x = 1, grid.width do
        if grid.cells[y][x] == 1 then
            io.write("# ")
        else
            io.write(". ")
        end
    end
    print("")
end

print("\n" .. string.rep("=", 50))

-- Ввод стартовой точки
local start_x, start_y
repeat
    print("\nEnter start point:")
    start_x, start_y = get_coordinates("Start point:")
until is_valid_coordinate(start_x, start_y, grid)

-- Ввод целевой точки
local goal_x, goal_y
repeat
    print("\nEnter goal point:")
    goal_x, goal_y = get_coordinates("Goal point:")
    if goal_x == start_x and goal_y == start_y then
        print("Error: goal cannot be the same as start!")
        goal_x = nil
    end
until is_valid_coordinate(goal_x, goal_y, grid)

-- Создаем пошаговый решатель
local solver = AStarStepped.new(grid, start_x, start_y, goal_x, goal_y)

-- Состояние
local current_state = {
    current_node = nil,
    open_list = {},
    closed_list = {},
    neighbors_info = {}
}
local finished = false
local mode = "simple"  -- simple, g, h, f

-- Главный цикл
local running = true
while running do
    Viz.clear_screen()
    
    -- Обновляем текущее состояние из solver
    if not finished then
        local neighbors_info = get_safe_neighbors_info(solver)
        current_state = {
            current_node = solver.current_node,
            open_list = solver.open_list,
            closed_list = solver.closed_list,
            neighbors_info = neighbors_info
        }
    end
    
    -- Отрисовка
    Viz.draw_menu(mode)
    Viz.draw_grid(grid, current_state, mode, start_x, start_y, goal_x, goal_y)
    
    print("")
    
    -- Показываем информацию о соседях
    if current_state.neighbors_info and #current_state.neighbors_info > 0 then
        Viz.draw_neighbors_info(current_state.neighbors_info)
        print("")
    end
    
    -- Показываем Open List
    if #current_state.open_list > 0 then
        local best = nil
        if solver and solver.find_best_node then
            best = solver:find_best_node()
        end
        Viz.draw_open_list(current_state.open_list, best)
        print("")
    end
    
    -- Статистика
    Viz.draw_stats(
        solver.step_count,
        #current_state.open_list,
        #current_state.closed_list
    )
    
    -- Если алгоритм завершен, показываем результат
    if finished or solver.finished then
        if not finished then
            finished = true
            if solver.found then
                local path = solver:get_path()
                print("\n" .. string.rep("=", 50))
                Viz.set_color("bright_green")
                print("✅ PATH FOUND!")
                Viz.reset_color()
                print(string.format("Length: %d steps", #path))
                print("\nPath coordinates:")
                for i, p in ipairs(path) do
                    local marker = ""
                    if i == 1 then marker = " (start)"
                    elseif i == #path then marker = " (goal)" end
                    print(string.format("  %2d: (%d, %d)%s", i, p.x, p.y, marker))
                end
            else
                print("\n" .. string.rep("=", 50))
                Viz.set_color("bright_red")
                print("❌ NO PATH FOUND!")
                Viz.reset_color()
                print("The goal is unreachable from the start point.")
            end
        end
        
        print("\nPress [Q] to quit, or any other key to continue...")
        local key = io.read()
        if key and key:lower() == "q" then
            running = false
        end
    else
        -- Ждем команду пользователя
        print("\nPress [Enter] for next step, [G/H/F/S] to change mode, [Q] to quit...")
        local cmd = read_key()
        
        if cmd == "enter" then
            -- Выполняем один шаг
            local step_result = solver:step()
            if step_result and step_result.finished then
                finished = true
            end
        elseif cmd == "g" then
            mode = "g"
        elseif cmd == "h" then
            mode = "h"
        elseif cmd == "f" then
            mode = "f"
        elseif cmd == "s" then
            mode = "simple"
        elseif cmd == "q" then
            running = false
        end
    end
end

print("\nGoodbye!")