-- astar.lua
-- Реализация алгоритма A*

local Node = require("node")

local AStar = {}

---Эвристическая функция (Манхэттенское расстояние)
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function AStar.heuristic(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

---Находим узел в списке по координатам
---@param list table
---@param x number
---@param y number
---@return Node|nil
local function find_node(list, x, y)
    for _, node in ipairs(list) do
        if node.x == x and node.y == y then
            return node
        end
    end
    return nil
end

---Восстанавливаем путь от цели до старта
---@param end_node Node
---@return table
local function reconstruct_path(end_node)
    local path = {}
    local current = end_node
    
    while current do
        table.insert(path, 1, {x = current.x, y = current.y})
        current = current.parent
    end
    
    return path
end

---Основная функция A*
---@param grid Grid
---@param start_x number
---@param start_y number
---@param goal_x number
---@param goal_y number
---@return table|nil  -- путь или nil, если путь не найден
function AStar.find_path(grid, start_x, start_y, goal_x, goal_y)
    -- Проверка стартовой и конечной точек
    if not grid:is_walkable(start_x, start_y) then
        print("Start cell is blocked!")
        return nil
    end
    if not grid:is_walkable(goal_x, goal_y) then
        print("Target cell is blocked!")
        return nil
    end
    
    -- Инициализация
    local open_list = {}      -- узлы для рассмотрения
    local closed_list = {}    -- уже рассмотренные узлы
    
    -- Создаем стартовый узел
    local start_node = Node.new(start_x, start_y)
    start_node.g = 0
    start_node.h = AStar.heuristic(start_x, start_y, goal_x, goal_y)
    start_node.f = start_node.h
    
    table.insert(open_list, start_node)
    
    -- Основной цикл
    while #open_list > 0 do
        -- Находим узел с наименьшей стоимостью F
        local current_index = 1
        for i = 2, #open_list do
            if open_list[i].f < open_list[current_index].f then
                current_index = i
            end
        end
        local current = open_list[current_index]
        
        -- Проверка, достигли ли мы цели
        if current.x == goal_x and current.y == goal_y then
            return reconstruct_path(current)
        end
        
        -- Перемещаем текущий узел из open в closed
        table.remove(open_list, current_index)
        table.insert(closed_list, current)
        
        -- Обрабатываем соседей
        local neighbors = grid:get_neighbors(current)
        
        for _, neighbor_pos in ipairs(neighbors) do
            -- Проверяем, не в closed ли списке
            if not find_node(closed_list, neighbor_pos.x, neighbor_pos.y) then
                -- Создаем временный узел для соседа
                local neighbor = find_node(open_list, neighbor_pos.x, neighbor_pos.y)
                local is_new = false
                
                if not neighbor then
                    neighbor = Node.new(neighbor_pos.x, neighbor_pos.y)
                    is_new = true
                end
                
                -- Вычисляем новую стоимость G
                local g_score = current.g + 1  -- стоимость перехода = 1
                
                -- Если это лучший путь или новый узел
                if is_new or g_score < neighbor.g then
                    neighbor.parent = current
                    neighbor.g = g_score
                    neighbor.h = AStar.heuristic(neighbor.x, neighbor.y, goal_x, goal_y)
                    neighbor.f = neighbor.g + neighbor.h
                    
                    if is_new then
                        table.insert(open_list, neighbor)
                    end
                end
            end
        end
    end
    
    -- Если open_list пуст, путь не найден
    print("Path is not found!")
    return nil
end

return AStar