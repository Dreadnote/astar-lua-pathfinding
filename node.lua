-- node.lua
-- Класс узла для алгоритма A*

---@class Node
---@field x number
---@field y number
---@field g number  -- стоимость от старта до текущего узла
---@field h number  -- эвристическая стоимость до цели
---@field f number  -- общая стоимость (g + h)
---@field parent Node|nil  -- родительский узел для восстановления пути

local Node = {}
Node.__index = Node

---Создает новый узел
---@param x number
---@param y number
---@return Node
function Node.new(x, y)
    local self = setmetatable({}, Node)
    self.x = x
    self.y = y
    self.g = 0
    self.h = 0
    self.f = 0
    self.parent = nil
    return self
end

---Сравнивает два узла по координатам
---@param other Node
---@return boolean
function Node:equals(other)
    return self.x == other.x and self.y == other.y
end

---Сравнивает по координатам (для поиска)
---@param x number
---@param y number
---@return boolean
function Node:equals_coords(x, y)
    return self.x == x and self.y == y
end

---Копирует данные из другого узла
---@param other Node
function Node:copy_from(other)
    self.g = other.g
    self.h = other.h
    self.f = other.f
    self.parent = other.parent
end

return Node