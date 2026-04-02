-- main.lua
-- A* Pathfinding с пошаговой визуализацией

package.path = "./?.lua;" .. package.path

local Grid = require("grid")
local AStarStepped = require("astar_stepped")
local Viz = require("visualization")

-- Лабиринт 21x20 с туннелями и комнатами
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

local function get_coordinates(prompt)
    print(prompt)
    io.write("X: ")
    local x = tonumber(io.read())
    io.write("Y: ")
    local y = tonumber(io.read())
    return x, y
end

local function is_valid_coordinate(x, y, grid)
    if not x or not y then
        print("Error: please enter numbers!")
        return false
    end
    if x < 1 or x > grid.width or y < 1 or y > grid.height then
        print(string.format("Error: coordinates must be from 1 to %d for X and from 1 to %d for Y", grid.width, grid.height))
        return false
    end
    if not grid:is_walkable(x, y) then
        print("Error: this cell is a wall!")
        return false
    end
    return true
end

local function read_key()
    local key = io.read()
    if key == "" then return "enter" end
    key = key:lower()
    if key == "g" then return "g"
    elseif key == "h" then return "h"
    elseif key == "f" then return "f"
    elseif key == "s" then return "s"
    elseif key == "q" then return "q"
    elseif key == "r" then return "r"
    else return nil end
end

local function choose_execution_mode()
    print("\n" .. string.rep("=", 50))
    print("Select execution mode:")
    print("  [1] Step-by-step mode (press Enter for each step)")
    print("  [2] Auto mode (runs until path is found or no path exists)")
    print(string.rep("=", 50))
    while true do
        io.write("Your choice (1 or 2): ")
        local choice = io.read()
        if choice == "1" then return "step"
        elseif choice == "2" then return "auto"
        else print("Invalid choice. Please enter 1 or 2.") end
    end
end

local function choose_auto_display_mode()
    print("\n" .. string.rep("=", 50))
    print("Select display mode for auto execution:")
    print("  [1] Show intermediate results (every 10 steps)")
    print("  [2] Show only final result")
    print(string.rep("=", 50))
    while true do
        io.write("Your choice (1 or 2): ")
        local choice = io.read()
        if choice == "1" then return "intermediate"
        elseif choice == "2" then return "final_only"
        else print("Invalid choice. Please enter 1 or 2.") end
    end
end

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
        if choice == "s" then return "simple"
        elseif choice == "g" then return "g"
        elseif choice == "h" then return "h"
        elseif choice == "f" then return "f"
        else print("Invalid choice. Please enter S, G, H or F.") end
    end
end

local function show_maze_for_input()
    print("=== A* Pathfinding Algorithm ===\n")
    print("Maze layout (coordinates shown):\n")
    io.write("   ")
    for x = 1, grid.width do io.write(string.format("%2d ", x)) end
    print("\n   " .. string.rep("---", grid.width))
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
    print("\nLegend: . = walkable, # = wall")
    print(string.rep("=", 50))
end

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

local function display_state(solver, mode, start_x, start_y, goal_x, goal_y, step_num)
    local state = {
        current_node = solver.current_node, open_list = solver.open_list,
        closed_list = solver.closed_list, neighbors_info = solver:get_neighbors_info(),
        final_path = solver.final_path
    }
    print(string.rep("=", 80))
    print(string.format("=== STEP %d ===", step_num))
    print(string.rep("=", 80) .. "\n")
    Viz.draw_menu(mode)
    if state.current_node and #state.neighbors_info > 0 then
        Viz.draw_neighbors_info(state.neighbors_info)
        print("")
    end
    if #state.open_list > 0 then
        Viz.draw_open_list(state.open_list, solver:find_best_node())
        print("")
    end
    Viz.draw_grid(grid, state, mode, start_x, start_y, goal_x, goal_y)
    print("")
    Viz.draw_stats(solver.step_count, #state.open_list, #state.closed_list)
    print("")
end

local function run_auto_mode(solver, mode, display_mode, start_x, start_y, goal_x, goal_y)
    local last_display = 0
    while not solver.finished and solver.step_count < 10000 do
        solver:step()
        if display_mode == "intermediate" and (solver.finished or solver.step_count - last_display >= 10) then
            display_state(solver, mode, start_x, start_y, goal_x, goal_y, solver.step_count)
            last_display = solver.step_count
        end
    end
end

-- Основная программа
local running = true
while running do
    local start_x, start_y, goal_x, goal_y = get_start_and_goal()
    local exec_mode = choose_execution_mode()
    
    if exec_mode == "auto" then
        local display_mode = choose_auto_display_mode()
        local mode = choose_visualization_mode()
        local solver = AStarStepped.new(grid, start_x, start_y, goal_x, goal_y)
        
        print("\nRunning in AUTO mode... Please wait.\n")
        if display_mode == "intermediate" then print("Intermediate results every 10 steps.\n") end
        
        run_auto_mode(solver, mode, display_mode, start_x, start_y, goal_x, goal_y)
        
        print(string.rep("=", 80) .. "\n=== FINAL RESULT ===\n" .. string.rep("=", 80))
        display_state(solver, mode, start_x, start_y, goal_x, goal_y, solver.step_count)
        
        if solver.found then
            local path = solver:get_path()
            print("\n" .. string.rep("=", 50))
            Viz.set_color("bright_green")
            print("PATH FOUND!")
            Viz.reset_color()
            print(string.format("Length: %d steps", #path))
            print("\nPath coordinates:")
            for i, p in ipairs(path) do
                local marker = i == 1 and " (START)" or (i == #path and " (GOAL)" or "")
                print(string.format("  %2d: (%d, %d)%s", i, p.x, p.y, marker))
            end
        else
            print("\n" .. string.rep("=", 50))
            Viz.set_color("bright_red")
            print("NO PATH FOUND!")
            Viz.reset_color()
            print("The goal is unreachable from the start point.")
        end
        
        print("\n[R] Restart | [Q] Quit")
        if read_key() == "q" then running = false end
        
    else -- Step-by-step mode
        local solver = AStarStepped.new(grid, start_x, start_y, goal_x, goal_y)
        local mode, path_shown = "simple", false
        local step_running = true
        
        while step_running do
            display_state(solver, mode, start_x, start_y, goal_x, goal_y, solver.step_count + 1)
            
            if solver.finished then
                if not path_shown then
                    path_shown = true
                    if solver.found then
                        local path = solver:get_path()
                        print("\n" .. string.rep("=", 50))
                        Viz.set_color("bright_green")
                        print("PATH FOUND!")
                        Viz.reset_color()
                        print(string.format("Length: %d steps", #path))
                        print("\nPath coordinates:")
                        for i, p in ipairs(path) do
                            local marker = i == 1 and " (START)" or (i == #path and " (GOAL)" or "")
                            print(string.format("  %2d: (%d, %d)%s", i, p.x, p.y, marker))
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
                
                print("\n[F] F-cost | [G] G-cost | [H] H-cost | [S] Simple | [R] Restart | [Q] Quit")
                local cmd = read_key()
                if cmd == "g" then mode = "g"
                elseif cmd == "h" then mode = "h"
                elseif cmd == "f" then mode = "f"
                elseif cmd == "s" then mode = "simple"
                elseif cmd == "r" then step_running = false
                elseif cmd == "q" then step_running = false; running = false end
            else
                print("\n[Enter] next step | [G] G-cost | [H] H-cost | [F] F-cost | [S] Simple | [Q] Quit")
                local cmd = read_key()
                if cmd == "enter" then solver:step()
                elseif cmd == "g" then mode = "g"
                elseif cmd == "h" then mode = "h"
                elseif cmd == "f" then mode = "f"
                elseif cmd == "s" then mode = "simple"
                elseif cmd == "q" then step_running = false; running = false end
            end
        end
    end
end

print("\nGoodbye!")