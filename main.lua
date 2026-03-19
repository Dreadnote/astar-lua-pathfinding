-- main.lua
-- Тестирование алгоритма A*

local Grid = require("grid")
local AStar = require("astar")

-- Пример лабиринта (0 - проходимо, 1 - стена)
local maze_data = {
    {0, 0, 0, 0, 0, 0, 0, 0},
    {0, 1, 1, 1, 1, 0, 1, 0},
    {0, 1, 0, 0, 0, 0, 1, 0},
    {1, 1, 0, 1, 1, 1, 1, 0},
    {0, 0, 0, 1, 0, 0, 0, 0},
    {0, 1, 1, 1, 0, 1, 1, 0},
    {0, 0, 0, 0, 0, 0, 0, 0}
}

-- Создаем сетку
local grid = Grid.new(maze_data)

print("Maze (0 - empty, 1 - wall):")
grid:print()

print("\n" .. string.rep("-", 30))

-- Задаем старт и цель
local start_x, start_y = 1, 1    -- левый верхний угол
local goal_x, goal_y = 8, 7      -- правый нижний угол

print(string.format("Find a path from (%d,%d) to (%d,%d)...", start_x, start_y, goal_x, goal_y))

-- Запускаем A*
local path = AStar.find_path(grid, start_x, start_y, goal_x, goal_y)

if path then
    print(string.format("\nPath is found! Length: %d steps", #path))
    print("\nMaze and Path (* - path, # - wall, . - empty):")
    grid:print(path)
    
    print("\nCoordinates:")
    for i, point in ipairs(path) do
        print(string.format("%d: (%d, %d)", i, point.x, point.y))
    end
else
    print("Path is not found!")
end