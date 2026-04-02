-- main.lua
-- A* Pathfinding с пошаговой визуализацией

package.path = "./?.lua;" .. package.path

local Grid = require("grid")
local AStarStepped = require("astar_stepped")
local Viz = require("visualization")

-- Лабиринт с туннелями и открытыми комнатами 20x20
local maze_data = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1},
    {1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1},
    {1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1},
    {1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
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

-- Функция для чтения клавиши
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
    elseif key == "r" then return "r"
    else return nil
    end
end

-- Функция для выбора режима выполнения
local function choose_execution_mode()
    print("\n" .. string.rep("=", 50))
    print("Select execution mode:")
    print("  [1] Step-by-step mode (press Enter for each step)")
    print("  [2] Auto mode (runs until path is found or no path exists)")
    print(string.rep("=", 50))
    
    while true do
        io.write("Your choice (1 or 2): ")
        local choice = io.read()
        if choice == "1" then
            return "step"
        elseif choice == "2" then
            return "auto"
        else
            print("Invalid choice. Please enter 1 or 2.")
        end
    end
end

-- Функция для выбора режима отображения в авторежиме
local function choose_auto_display_mode()
    print("\n" .. string.rep("=", 50))
    print("Select display mode for auto execution:")
    print("  [1] Show intermediate results (every 10 steps)")
    print("  [2] Show only final result")
    print(string.rep("=", 50))
    
    while true do
        io.write("Your choice (1 or 2): ")
        local choice = io.read()
        if choice == "1" then
            return "intermediate"
        elseif choice == "2" then
            return "final_only"
        else
            print("Invalid choice. Please enter 1 or 2.")
        end
    end
end

-- Функция для выбора стартового режима визуализации
local function choose_visualization_mode()
    print("\n" .. string.rep("=", 50))
    print("Select visualization mode:")
    print("  [S] Simple mode (symbols: S, G, @, ?, ., *, #)")
    print("  [G] G-cost mode (distance from start)")
    print("  [H] H-cost mode (heuristic distance to goal)")
    print("  [F] F-cost mode (total estimated cost)")
    print(string.rep("=", 50))
    
    while true do
        io.write("Your choice (S, G, H, F): ")
        local choice = io.read():lower()
        if choice == "s" then
            return "simple"
        elseif choice == "g" then
            return "g"
        elseif choice == "h" then
            return "h"
        elseif choice == "f" then
            return "f"
        else
            print("Invalid choice. Please enter S, G, H or F.")
        end
    end
end

-- Показываем лабиринт для ввода
local function show_maze_for_input()
    print("=== A* Pathfinding Algorithm ===\n")
    print("Maze layout (coordinates shown):")
    print("")
    
    io.write("   ")
    for x = 1, grid.width do
        io.write(string.format("%2d ", x))
    end
    print("")
    
    io.write("   ")
    for x = 1, grid.width do
        io.write("---")
    end
    print("")
    
    for y = 1, grid.height do
        io.write(string.format("%2d|", y))
        for x = 1, grid.width do
            io.write(" ")
            if grid.cells[y][x] == 1 then
                Viz.set_color("bright_black")
                io.write("#")
                Viz.reset_color()
            else
                io.write(".")
            end
            io.write(" ")
        end
        print("")
    end
    print("")
    print("Legend: . = walkable, # = wall")
    print(string.rep("=", 50))
end

-- Функция для получения старта и цели
local function get_start_and_goal()
    show_maze_for_input()
    
    local start_x, start_y
    repeat
        print("\nEnter START point (use coordinates from the map above):")
        start_x, start_y = get_coordinates("Start point:")
    until is_valid_coordinate(start_x, start_y, grid)
    
    local goal_x, goal_y
    repeat
        print("\nEnter GOAL point:")
        goal_x, goal_y = get_coordinates("Goal point:")
        if goal_x == start_x and goal_y == start_y then
            print("Error: goal cannot be the same as start!")
            goal_x = nil
        end
    until is_valid_coordinate(goal_x, goal_y, grid)
    
    return start_x, start_y, goal_x, goal_y
end

-- Функция для отображения состояния алгоритма
local function display_state(solver, mode, start_x, start_y, goal_x, goal_y, step_num)
    local current_state = {
        current_node = solver.current_node,
        open_list = solver.open_list,
        closed_list = solver.closed_list,
        neighbors_info = solver:get_neighbors_info(),
        final_path = solver.final_path
    }
    
    print(string.rep("=", 80))
    print(string.format("=== STEP %d ===", step_num))
    print(string.rep("=", 80))
    print("")
    
    Viz.draw_menu(mode)
    
    if current_state.current_node and current_state.neighbors_info and #current_state.neighbors_info > 0 then
        Viz.draw_neighbors_info(current_state.neighbors_info)
        print("")
    end
    
    if #current_state.open_list > 0 then
        local best = solver:find_best_node()
        Viz.draw_open_list(current_state.open_list, best)
        print("")
    end
    
    Viz.draw_grid(grid, current_state, mode, start_x, start_y, goal_x, goal_y)
    print("")
    
    Viz.draw_stats(solver.step_count, #current_state.open_list, #current_state.closed_list)
    print("")
end

-- Функция для автоматического выполнения алгоритма
local function run_auto_mode(solver, grid, start_x, start_y, goal_x, goal_y, mode, display_mode)
    local step_result = nil
    local max_steps = 10000  -- Защита от бесконечного цикла
    local last_display_step = 0
    
    while not solver.finished and solver.step_count < max_steps do
        step_result = solver:step()
        
        -- Отображаем промежуточные результаты если нужно
        if display_mode == "intermediate" then
            -- Показываем каждый 10-й шаг или последний
            if solver.finished or solver.step_count - last_display_step >= 10 then
                display_state(solver, mode, start_x, start_y, goal_x, goal_y, solver.step_count)
                last_display_step = solver.step_count
                
                -- Небольшая задержка для читаемости (опционально)
                -- os.execute("timeout /t 0 /nobreak > nul")
            end
        end
    end
    
    return step_result
end

-- Основная программа
local running = true
while running do
    -- Получаем координаты
    local start_x, start_y, goal_x, goal_y = get_start_and_goal()
    
    -- Выбираем режим выполнения
    local exec_mode = choose_execution_mode()
    
    if exec_mode == "auto" then
        -- Выбираем режим отображения для авторежима
        local display_mode = choose_auto_display_mode()
        
        -- Выбираем стартовый режим визуализации
        local mode = choose_visualization_mode()
        
        -- Создаем пошаговый решатель
        local solver = AStarStepped.new(grid, start_x, start_y, goal_x, goal_y)
        
        print("\nRunning in AUTO mode... Please wait.\n")
        
        if display_mode == "intermediate" then
            print("Intermediate results will be shown every 10 steps.\n")
        else
            print("Only final result will be shown.\n")
        end
        
        local final_result = run_auto_mode(solver, grid, start_x, start_y, goal_x, goal_y, mode, display_mode)
        
        -- Финальный вывод
        print(string.rep("=", 80))
        print("=== FINAL RESULT ===")
        print(string.rep("=", 80))
        
        local current_state = {
            current_node = solver.current_node,
            open_list = solver.open_list,
            closed_list = solver.closed_list,
            neighbors_info = solver:get_neighbors_info(),
            final_path = solver.final_path
        }
        
        Viz.draw_menu(mode)
        Viz.draw_grid(grid, current_state, mode, start_x, start_y, goal_x, goal_y)
        print("")
        Viz.draw_stats(solver.step_count, #current_state.open_list, #current_state.closed_list)
        
        if solver.finished and solver.found then
            local path = solver:get_path()
            print("\n" .. string.rep("=", 50))
            Viz.set_color("bright_green")
            print("PATH FOUND!")
            Viz.reset_color()
            
            if path and #path > 0 then
                print(string.format("Length: %d steps", #path))
                print("\nPath coordinates:")
                for i, p in ipairs(path) do
                    local marker = ""
                    if i == 1 then marker = " (START)"
                    elseif i == #path then marker = " (GOAL)" end
                    print(string.format("  %2d: (%d, %d)%s", i, p.x, p.y, marker))
                end
            end
        elseif solver.finished and not solver.found then
            print("\n" .. string.rep("=", 50))
            Viz.set_color("bright_red")
            print("NO PATH FOUND!")
            Viz.reset_color()
            print("The goal is unreachable from the start point.")
        end
        
        print("\n[R] Restart with new coordinates | [Q] Quit")
        local cmd = read_key()
        if cmd == "q" then
            running = false
        end
        
    else
        -- Пошаговый режим (оригинальный)
        local solver = AStarStepped.new(grid, start_x, start_y, goal_x, goal_y)
        
        local current_state = {
            current_node = nil,
            open_list = {},
            closed_list = {},
            neighbors_info = {},
            final_path = nil
        }
        local mode = "simple"
        local path_shown = false
        
        local algorithm_running = true
        while algorithm_running do
            print(string.rep("=", 80))
            print(string.format("=== STEP %d ===", solver.step_count + 1))
            print(string.rep("=", 80))
            print("")
            
            current_state = {
                current_node = solver.current_node,
                open_list = solver.open_list,
                closed_list = solver.closed_list,
                neighbors_info = solver:get_neighbors_info(),
                final_path = solver.final_path
            }
            
            Viz.draw_menu(mode)
            
            if not solver.finished and current_state.current_node and current_state.neighbors_info and #current_state.neighbors_info > 0 then
                Viz.draw_neighbors_info(current_state.neighbors_info)
                print("")
            end
            
            if not solver.finished and #current_state.open_list > 0 then
                local best = solver:find_best_node()
                Viz.draw_open_list(current_state.open_list, best)
                print("")
            end
            
            Viz.draw_grid(grid, current_state, mode, start_x, start_y, goal_x, goal_y)
            print("")
            
            Viz.draw_stats(
                solver.step_count,
                #current_state.open_list,
                #current_state.closed_list
            )
            
            if solver.finished and not path_shown then
                path_shown = true
                if solver.found then
                    local path = solver:get_path()
                    print("\n" .. string.rep("=", 50))
                    Viz.set_color("bright_green")
                    print("PATH FOUND!")
                    Viz.reset_color()
                    
                    if path and #path > 0 then
                        print(string.format("Length: %d steps", #path))
                        print("\nPath coordinates:")
                        for i, p in ipairs(path) do
                            local marker = ""
                            if i == 1 then marker = " (START)"
                            elseif i == #path then marker = " (GOAL)" end
                            print(string.format("  %2d: (%d, %d)%s", i, p.x, p.y, marker))
                        end
                    end
                else
                    print("\n" .. string.rep("=", 50))
                    Viz.set_color("bright_red")
                    print("NO PATH FOUND!")
                    Viz.reset_color()
                    print("The goal is unreachable from the start point.")
                end
                print("\nPress any key to continue...")
                io.read()
            end
            
            if solver.finished then
                print("\n[F] F-cost | [G] G-cost | [H] H-cost | [S] Simple | [R] Restart | [Q] Quit")
                local cmd = read_key()
                
                if cmd == "g" then
                    mode = "g"
                elseif cmd == "h" then
                    mode = "h"
                elseif cmd == "f" then
                    mode = "f"
                elseif cmd == "s" then
                    mode = "simple"
                elseif cmd == "r" then
                    algorithm_running = false
                elseif cmd == "q" then
                    algorithm_running = false
                    running = false
                end
            else
                print("\n[Enter] next step | [G] G-cost | [H] H-cost | [F] F-cost | [S] Simple | [Q] Quit")
                local cmd = read_key()
                
                if cmd == "enter" then
                    solver:step()
                elseif cmd == "g" then
                    mode = "g"
                elseif cmd == "h" then
                    mode = "h"
                elseif cmd == "f" then
                    mode = "f"
                elseif cmd == "s" then
                    mode = "simple"
                elseif cmd == "q" then
                    algorithm_running = false
                    running = false
                end
            end
        end
    end
end

print("\nGoodbye!")