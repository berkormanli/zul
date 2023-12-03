-- Define the KDTree class
KDTree = zlib.class()
--[[
    KDTree
]]

-- Node structure
local Node = {}
Node.__index = Node

function Node.new(point, axis)
    local node = {}
    node.point = point
    node.axis = axis
    node.left = nil
    node.right = nil
    return setmetatable(node, Node)
end

-- Constructor
function KDTree:__init(points)
    self.root = KDTree:_buildTree(points)
end

-- Build a balanced KD-tree from a list of points
function KDTree:_buildTree(points, axis)
    if #points == 0 then
        return nil
    end

    axis = axis or 1
    local midIndex = math.floor(#points / 2)

    -- Sort points by the current axis
    table.sort(points, function(a, b)
        return a[axis] < b[axis]
    end)

    -- Create the node for the median point
    local median = points[midIndex]
    local node = Node.new(median, axis)

    -- Recursively build the left and right subtrees
    local nextAxis = (axis % #median) + 1
    node.left = KDTree:_buildTree({ table.unpack(points, 1, midIndex - 1) }, nextAxis)
    node.right = KDTree:_buildTree({ table.unpack(points, midIndex + 1) }, nextAxis)

    return node
end

-- Find the nearest neighbor to a given point in the KD-tree
function KDTree:findNearestNeighbor(point)
    local nearest = nil
    local bestDistance = math.huge

    local function search(node, target, axis)
        if not node then
            return
        end

        -- Check the current node
        local distance = KDTree:_distance(node.point, target)
        if distance < bestDistance then
            nearest = node.point
            bestDistance = distance
        end

        -- Recursively search the appropriate subtree
        local nextAxis = (axis % #target) + 1
        if target[axis] < node.point[axis] then
            search(node.left, target, nextAxis)
            if target[axis] + bestDistance >= node.point[axis] then
                search(node.right, target, nextAxis)
            end
        else
            search(node.right, target, nextAxis)
            if target[axis] - bestDistance <= node.point[axis] then
                search(node.left, target, nextAxis)
            end
        end
    end

    search(self.root, point, 1)

    return nearest
end

-- Calculate the Euclidean distance between two points
function KDTree:_distance(point1, point2)
    local sum = 0
    for i = 1, #point1 do
        local diff = point1[i] - point2[i]
        sum = sum + (diff * diff)
    end
    return math.sqrt(sum)
end

-- Example usage
local points = {
    { 2, 3 },
    { 5, 4 },
    { 9, 6 },
    { 4, 7 },
    { 8, 1 },
    { 7, 2 }
}

local myKDTree = KDTree(points)

local nearestNeighbor = myKDTree:findNearestNeighbor({ 6, 5 })
print(nearestNeighbor[1], nearestNeighbor[2]) --> 5 4
