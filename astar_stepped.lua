-- astar_stepped.lua
-- Пошаговая реализация алгоритма A*

local Node = require("node")
local AStarStepped = {}

function AStarStepped.heuristic(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

function AStarStepped.new(grid, start_x, start_y, goal_x, goal_y)
    local self = {}
    self.grid = grid
    self.start_x = start_x
    self.start_y = start_y
    self.goal_x = goal_x
    self.goal_y = goal_y
    
    self.open_list = {}
    self.closed_list = {}
    self.current_node = nil
    self.finished = false
    self.found = false
    self.final_path = nil
    self.step_count = 0
    
    local heuristic = AStarStepped.heuristic
    
    -- Стартовый узел
    local start_node = Node.new(start_x, start_y)
    start_node.g = 0
    start_node.h = heuristic(start_x, start_y, goal_x, goal_y)
    start_node.f = start_node.g + start_node.h
    start_node.parent = nil
    table.insert(self.open_list, start_node)
    
    -- Поиск узла с минимальным F (при равенстве - по H)
    self.find_best_node = function()
        if #self.open_list == 0 then
            return nil
        end
        local best = self.open_list[1]
        for i = 2, #self.open_list do
            local current = self.open_list[i]
            if current.f < best.f then
                best = current
            elseif current.f == best.f and current.h < best.h then
                best = current
            end
        end
        return best
    end
    
    -- Информация о соседях текущего узла
    self.get_neighbors_info = function()
        if not self.current_node then
            return {}
        end
        
        local neighbors_info = {}
        local neighbors = self.grid:get_neighbors(self.current_node)
        
        for _, n in ipairs(neighbors) do
            local g = self.current_node.g + 1
            local h = heuristic(n.x, n.y, self.goal_x, self.goal_y)
            local f = g + h
            
            local status = "new"
            local existing = self.grid:find_in_list(self.open_list, n.x, n.y)
            
            if self.grid:is_in_list(self.closed_list, n.x, n.y) then
                status = "closed"
            elseif existing then
                status = "in_open"
            end
            
            table.insert(neighbors_info, {
                x = n.x, y = n.y, g = g, h = h, f = f, status = status
            })
        end
        return neighbors_info
    end
    
    -- Восстановление пути от цели к старту
    self.reconstruct_path = function()
        local path = {}
        local current = self.current_node
        while current do
            table.insert(path, 1, {x = current.x, y = current.y})
            current = current.parent
        end
        return path
    end
    
    -- Один шаг алгоритма
    self.step = function()
        if self.finished then
            return nil
        end
        
        self.step_count = self.step_count + 1
        local current = self:find_best_node()
        
        if not current then
            self.finished = true
            self.found = false
            return {finished = true, found = false}
        end
        
        -- Проверка достижения цели
        if current.x == self.goal_x and current.y == self.goal_y then
            self.finished = true
            self.found = true
            self.current_node = current
            self.final_path = self:reconstruct_path()
            return {
                finished = true, found = true, current_node = current,
                open_list = self.open_list, closed_list = self.closed_list,
                neighbors_info = {}, step_count = self.step_count,
                final_path = self.final_path
            }
        end
        
        -- Перемещаем текущий узел из open в closed
        for i, node in ipairs(self.open_list) do
            if node == current then
                table.remove(self.open_list, i)
                break
            end
        end
        table.insert(self.closed_list, current)
        self.current_node = current
        
        -- Обработка соседей
        local neighbors = self.grid:get_neighbors(current)
        for _, n in ipairs(neighbors) do
            if not self.grid:is_in_list(self.closed_list, n.x, n.y) then
                local new_g = current.g + 1
                local existing = self.grid:find_in_list(self.open_list, n.x, n.y)
                
                if not existing then
                    local neighbor = Node.new(n.x, n.y)
                    neighbor.g = new_g
                    neighbor.h = heuristic(n.x, n.y, self.goal_x, self.goal_y)
                    neighbor.f = neighbor.g + neighbor.h
                    neighbor.parent = current
                    table.insert(self.open_list, neighbor)
                elseif new_g < existing.g then
                    existing.g = new_g
                    existing.f = existing.g + existing.h
                    existing.parent = current
                end
            end
        end
        
        -- Сортировка open_list по F, затем по H
        table.sort(self.open_list, function(a, b)
            if a.f ~= b.f then return a.f < b.f else return a.h < b.h end
        end)
        
        return {
            finished = false, current_node = current, open_list = self.open_list,
            closed_list = self.closed_list, neighbors_info = self:get_neighbors_info(),
            step_count = self.step_count
        }
    end
    
    self.get_path = function()
        return self.final_path
    end
    
    return self
end

return AStarStepped