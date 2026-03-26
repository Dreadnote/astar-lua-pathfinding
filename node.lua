-- node.lua
-- Класс узла для алгоритма A*

local Node = {}
Node.__index = Node

function Node.new(x, y)
    local self = setmetatable({}, Node)
    self.x = x or 0
    self.y = y or 0
    self.g = 0
    self.h = 0
    self.f = 0
    self.parent = nil
    return self
end

function Node:equals(other)
    return self.x == other.x and self.y == other.y
end

function Node:equals_coords(x, y)
    return self.x == x and self.y == y
end

function Node:copy_from(other)
    self.g = other.g
    self.h = other.h
    self.f = other.f
    self.parent = other.parent
end

return Node