-- grid.lua
-- Класс для работы с сеткой лабиринта

---@class Grid
---@field width number
---@field height number
---@field cells number[][]  -- 0 - проходимо, 1 - стена

local Grid = {}
Grid.__index = Grid

---Создаем сетку из двумерного массива
---@param data number[][]
---@return Grid
function Grid.new(data)
    local self = setmetatable({}, Grid)
    self.cells = data
    self.height = #data
    self.width = self.height > 0 and #data[1] or 0
    return self
end

---Проверяем, проходима ли клетка
---@param x number
---@param y number
---@return boolean
function Grid:is_walkable(x, y)
    -- Проверяем границы
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return false
    end
    -- 0 - проходимо, 1 - стена
    return self.cells[y][x] == 0
end

---Возвращаем список ортогональных соседей для клетки
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

---Визуализируем сетку с путем
---@param path table|nil
function Grid:print(path)
    for y = 1, self.height do
        local line = ""
        for x = 1, self.width do
            if path then
                local in_path = false
                for _, p in ipairs(path) do
                    if p.x == x and p.y == y then
                        in_path = true
                        break
                    end
                end
                if in_path then
                    line = line .. "* "  -- путь
                elseif self.cells[y][x] == 1 then
                    line = line .. "# "  -- стена
                else
                    line = line .. ". "  -- пусто
                end
            else
                line = line .. tostring(self.cells[y][x]) .. " "
            end
        end
        print(line)
    end
end

return Grid