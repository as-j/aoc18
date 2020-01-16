#!/usr/bin/env lua

function distance(f, t)
    return math.abs(f[1] - t[1]) + math.abs(f[2] - t[2]) + math.abs(f[3] - t[3])
end

local bots = {}
local linear = {}

local file = io.open("input23.txt")
local max = 0
local max_bot = nil
while true do
    line = file:read("*l")
    if not line then break end
    local x,y,z,r = string.match(line, "^pos=<([^,]+),([^,]+),([^>]+)>, r=(.+)")
    print(x, y, z, r)
    table.insert(linear, {tonumber(x), tonumber(y), tonumber(z), tonumber(r)})
    if tonumber(r) > max then
        max_bot = {tonumber(x), tonumber(y), tonumber(z), tonumber(r)}
        max = tonumber(r)
    end
    if not bots[x] then bots[x] = {} end
    if not bots[x][y] then bots[x][y] = {} end
    bots[x][y][z] = { r = r }
end

print("max", max)
print("linear", #linear)

local rad = max_bot[4]
local num = 0
local num2 = 0

local max_x = math.mininteger
local min_x = math.maxinteger
local max_y = math.mininteger
local min_y = math.maxinteger
local max_z = math.mininteger
local min_z = math.maxinteger

for _,b in ipairs(linear) do
    local x = b[1]
    local y = b[2]
    local z = b[3]
    if x < min_x then min_x = x end
    if x > max_x then max_x = x end
    if y < min_y then min_y = y end
    if y > max_y then max_y = y end
    if z < min_z then min_z = z end
    if z > max_z then max_z = z end

    local d1 = max_bot[1] - b[1]
    if d1 < 0 then d1 = 0 - d1 end
    local d2 = max_bot[2] - b[2]
    if d2 < 0 then d2 = 0 - d2 end
    local d3 = max_bot[3] - b[3]
    if d3 < 0 then d3 = 0 - d3 end
    local d = d1+d2+d3
    if d <= rad then num = num + 1 end
    local d2 = distance(max_bot, b)
    if d <= rad then num2 = num2 + 1 end
end

print("num", num)
print("num2", num2)
print("max_x", max_x)
print("min_x", min_x)
print("max_y", max_y)
print("min_y", min_y)
print("max_z", max_z)
print("min_z", min_z)
print("size", max_x-min_x)

function get_range(divisor)
    local max_x = math.mininteger
    local min_x = math.maxinteger
    local max_y = math.mininteger
    local min_y = math.maxinteger
    local max_z = math.mininteger
    local min_z = math.maxinteger

    for _,b in ipairs(linear) do
        local x = b[1]//divisor
        local y = b[2]//divisor
        local z = b[3]//divisor
        if x < min_x then min_x = x end
        if x > max_x then max_x = x end
        if y < min_y then min_y = y end
        if y > max_y then max_y = y end
        if z < min_z then min_z = z end
        if z > max_z then max_z = z end

        local d1 = max_bot[1] - b[1]
        if d1 < 0 then d1 = 0 - d1 end
        local d2 = max_bot[2] - b[2]
        if d2 < 0 then d2 = 0 - d2 end
        local d3 = max_bot[3] - b[3]
        if d3 < 0 then d3 = 0 - d3 end
        local d = d1+d2+d3
        if d <= rad then num = num + 1 end
    end

    max_x = max_x + 1
    max_y = max_y + 1
    max_z = max_z + 1

    min_x = min_x
    min_y = min_y
    min_z = min_z

    --print("num", num)
    --print("max_x", max_x)
    --print("min_x", min_x)
    --print("max_y", max_y)
    --print("min_y", min_y)
    --print("max_z", max_z)
    --print("min_z", min_z)
    print("range", min_x, max_x, min_y, max_y, min_z, max_z, "size", (max_x-min_x)*(max_y-min_y)*(max_z-min_z), "div", divisor)
    return {
        max_x = max_x,
        min_x = min_x,
        max_y = max_y,
        min_y = min_y,
        max_z = max_z,
        min_z = min_z,
    }
end

function hunt(divisor, range)

    local num_table = {}
    local max = 0
    local nearest = {math.maxinteger, math.maxinteger, math.maxinteger}

    --print(range.min_y, range.max_y)
    for x = range.min_x-1,range.max_x+1 do
        for y = range.min_y-1,range.max_y+1 do
            for z = range.min_z-1,range.max_z+1 do
                if not num_table[x] then num_table[x] = {} end
                if not num_table[x][y] then num_table[x][y] = {} end
                if not num_table[x][y][z] then num_table[x][y][z] = 0 end
                for _, b in ipairs(linear) do
                    local n_x = math.floor(b[1]/divisor+0.5)
                    local n_y = math.floor(b[2]/divisor+0.5)
                    local n_z = math.floor(b[3]/divisor+0.5)
                    local n_r = math.floor(b[4]/divisor+0.5)
                    local d = distance({x,y,z},{n_x, n_y, n_z})
                    if d <= n_r then
                        num_table[x][y][z] = num_table[x][y][z] + 1
                    end
                    if num_table[x][y][z] > max then
                        max = num_table[x][y][z]
                        nearest = {x,y,z}
                    end
                end
            end
        end
    end
    print("max", max, "distance", distance(nearest, {0,0,0}))
    print("nearest", nearest[1], nearest[2], nearest[3], nmaxes)

    return nearest
end
function doo()

    local nearest = {math.maxinteger, math.maxinteger, math.maxinteger}
    local nmaxes = 0

    for x = range.min_x,range.max_x+1 do
        for y = range.min_y,range.max_y+1 do
            for z = range.min_z,range.max_z+1 do
                if num_table[x][y][z] == max then
                    local d_new = distance({x, y, z}, {0,0,0})
                    local d_cur = distance(nearest, {0,0,0})
                    if d_new < d_cur then
                        nmaxes = nmaxes + 1
                        nearest = {x,y,z}
                    end
                end
            end
        end
    end
    print("nearest", nearest[1], nearest[2], nearest[3], nmaxes)
    print("distance", distance(nearest, {0,0,0}))
    return nearest
end

local div = 100000000
local range = get_range(div)
print("div", div)

while (div > 1) do
    local nearest = hunt(div, range)
    range = {
        min_x = 10*nearest[1] - 10,
        max_x = 10*nearest[1] + 10,
        min_y = 10*nearest[2] - 10,
        max_y = 10*nearest[2] + 10,
        min_z = 10*nearest[3] - 10,
        max_z = 10*nearest[3] + 10,
    }
    print("range", range.min_x, range.max_x, range.min_y, range.max_y, range.min_z, range.max_z)
    div = div//10
    if div == 0 then
        div = 1
    end
    local range2 = get_range(div)
end

hunt(div, range)
