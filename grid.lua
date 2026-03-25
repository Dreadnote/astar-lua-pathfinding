-- grid.lua
-- Класс для работы с сеткой лабиринта

---@class Grid
---@field width number
---@field height number
---@field cells number[][]  -- 0 - проходимо, 1 - стена

local Grid = {}
Grid.__index = Grid

---Создает сетку из двумерного массива
---@param data number[][]
---@return Grid
function Grid.new(data)
    local self = setmetatable({}, Grid)
    self.cells = data
    self.height = #data
    self.width = self.height > 0 and #data[1] or 0
    return self
end

---Проверяет, проходима ли клетка
---@param x number
---@param y number
---@return boolean
function Grid:is_walkable(x, y)
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return false
    end
    return self.cells[y][x] == 0
end

---Возвращает список соседей для клетки (4 направления)
---@param node Node
---@return table
function Grid:get_neighbors(node)
    local neighbors = {}
    local directions = {
        {0, 1},   -- вверх
        {0, -1},  -- вниз
        {1, 0},   -- вправо
        {-1, 0},  -- влево
    }
    
    for _, dir in ipairs(directions) do
        local nx = node.x + dir[1]
        local ny = node.y + dir[2]
        
        if self:is_walkable(nx, ny) then
            table.insert(neighbors, {x = nx, y = ny})
        end
    end
    
    return neighbors
end

---Проверяет, находится ли узел в списке
---@param list table
---@param x number
---@param y number
---@return boolean
function Grid:is_in_list(list, x, y)
    for _, node in ipairs(list) do
        if node.x == x and node.y == y then
            return true
        end
    end
    return false
end

---Находит узел в списке
---@param list table
---@param x number
---@param y number
---@return Node|nil
function Grid:find_in_list(list, x, y)
    for _, node in ipairs(list) do
        if node.x == x and node.y == y then
            return node
        end
    end
    return nil
end

return Grid