-- astar_stepped.lua
-- Пошаговая реализация алгоритма A* для интерактивной визуализации

local Node = require("node")
local AStarStepped = {}

---Эвристическая функция (Манхэттенское расстояние)
function AStarStepped.heuristic(x1, y1, x2, y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end

---Создает новый пошаговый решатель
function AStarStepped.new(grid, start_x, start_y, goal_x, goal_y)
    local self = {}
    self.grid = grid
    self.start_x = start_x
    self.start_y = start_y
    self.goal_x = goal_x
    self.goal_y = goal_y
    
    -- Состояние алгоритма
    self.open_list = {}
    self.closed_list = {}
    self.current_node = nil
    self.finished = false
    self.found = false
    self.final_path = nil
    self.step_count = 0
    
    -- Инициализация
    local start_node = Node.new(start_x, start_y)
    start_node.g = 0
    start_node.h = AStarStepped.heuristic(start_x, start_y, goal_x, goal_y)
    start_node.f = start_node.h
    table.insert(self.open_list, start_node)
    
    -- Добавляем методы в объект
    self.find_best_node = function()
        if #self.open_list == 0 then
            return nil
        end
        local best = self.open_list[1]
        for i = 2, #self.open_list do
            if self.open_list[i].f < best.f then
                best = self.open_list[i]
            end
        end
        return best
    end
    
    self.get_neighbors_info = function()
        if not self.current_node then
            return {}
        end
        
        local neighbors_info = {}
        local neighbors = self.grid:get_neighbors(self.current_node)
        
        for _, n in ipairs(neighbors) do
            local g = self.current_node.g + 1
            local h = AStarStepped.heuristic(n.x, n.y, self.goal_x, self.goal_y)
            local f = g + h
            
            local status = "new"
            local existing = self.grid:find_in_list(self.open_list, n.x, n.y)
            
            if self.grid:is_in_list(self.closed_list, n.x, n.y) then
                status = "closed"
            elseif existing then
                status = "in_open"
                if g < existing.g then
                    status = "in_open_better"
                end
            end
            
            table.insert(neighbors_info, {
                x = n.x, y = n.y,
                g = g, h = h, f = f,
                status = status,
                existing_g = existing and existing.g or nil
            })
        end
        
        return neighbors_info
    end
    
    self.step = function()
        if self.finished then
            return nil
        end
        
        self.step_count = self.step_count + 1
        
        -- Находим лучший узел
        local current = self:find_best_node()
        if not current then
            self.finished = true
            self.found = false
            return {finished = true, found = false}
        end
        
        -- Удаляем из open, добавляем в closed
        for i, node in ipairs(self.open_list) do
            if node == current then
                table.remove(self.open_list, i)
                break
            end
        end
        table.insert(self.closed_list, current)
        self.current_node = current
        
        -- Проверка достижения цели
        if current.x == self.goal_x and current.y == self.goal_y then
            self.finished = true
            self.found = true
            self.final_path = self:reconstruct_path(current)
            return {
                finished = true,
                found = true,
                current_node = current,
                open_list = self.open_list,
                closed_list = self.closed_list,
                neighbors_info = self:get_neighbors_info(),
                step_count = self.step_count
            }
        end
        
        -- Получаем информацию о соседях до обработки
        local neighbors_info = self:get_neighbors_info()
        
        -- Обрабатываем соседей
        local neighbors = self.grid:get_neighbors(current)
        for _, n in ipairs(neighbors) do
            if not self.grid:is_in_list(self.closed_list, n.x, n.y) then
                local g_score = current.g + 1
                local existing = self.grid:find_in_list(self.open_list, n.x, n.y)
                
                if not existing then
                    local neighbor = Node.new(n.x, n.y)
                    neighbor.g = g_score
                    neighbor.h = AStarStepped.heuristic(n.x, n.y, self.goal_x, self.goal_y)
                    neighbor.f = neighbor.g + neighbor.h
                    neighbor.parent = current
                    table.insert(self.open_list, neighbor)
                elseif g_score < existing.g then
                    existing.g = g_score
                    existing.f = existing.g + existing.h
                    existing.parent = current
                end
            end
        end
        
        -- Сортируем open_list для отображения
        table.sort(self.open_list, function(a, b) return a.f < b.f end)
        
        return {
            finished = false,
            current_node = current,
            open_list = self.open_list,
            closed_list = self.closed_list,
            neighbors_info = neighbors_info,
            step_count = self.step_count
        }
    end
    
    self.reconstruct_path = function(end_node)
        local path = {}
        local current = end_node
        
        while current do
            table.insert(path, 1, {x = current.x, y = current.y})
            current = current.parent
        end
        
        return path
    end
    
    self.get_path = function()
        return self.final_path
    end
    
    return self
end

return AStarStepped