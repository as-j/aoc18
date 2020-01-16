#!/usr/local/bin/lua

--local depth = 510
--local target = {x = 10, y = 10}

local depth = 7863
local target = { x = 14,y  = 760}

local width = target.x
local height = target.y

local y0_x = 16807
local x0_y = 48271
local base_mod = 20183

local map = {}

for y=0,height do
    map[y] = {}
    for x=0,width do
        map[y][x] = {}
        if x == 0 and y == 0 then
            map[y][x]['geo'] = 0
        elseif x == target.x and y == target.y then
            map[y][x]['geo'] = 0
        elseif y == 0 then
            map[y][x]['geo'] = x * y0_x
        elseif x == 0 then
            map[y][x]['geo'] = y * x0_y
        else
            map[y][x]['geo'] = map[y-1][x].ero * map[y][x-1].ero
            print(x, y, map[y][x].geo)
        end
        map[y][x]['ero'] = (map[y][x]['geo'] + depth) % base_mod
        map[y][x]['type'] = (map[y][x]['ero']) % 3
        print(x, y, map[y][x].ero, map[y][x]['type'])
    end
end

local pmap = {}
local sum = 0
for y=0,height do
    local line = {}
    for x=0,width do
        local char = '.'
        sum = sum + map[y][x].type
        if map[y][x].type == 1 then char = '=' end
        if map[y][x].type == 2 then char = '|' end
        if x == 0 and y == 0 then char = 'M' end
        if y == target.y and x == target.x then char = 'T' end
        table.insert(line, char)
    end
    table.insert(pmap, table.concat(line))
    print(table.concat(line))
end
print("risk", sum)
