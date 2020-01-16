#!/usr/local/bin/lua

Bitmap = require "ppm"

local empty = {}
local pts = {}
local lines = io.open("input6.txt")
local line = lines:read("*all")
lines:close()

local max_pt = 0
local max_x = 0
local max_y = 0
for x,y in string.gmatch(line, "(%d+), (%d+)") do
    x = tonumber(x)
    y = tonumber(y)
    print(string.format("Input: %d: %s, %s", max_pt, x, y))
    if not empty[x] then empty[x] = {} end
    if empty[x][y] then
        error("Collision")
    end
    pts[max_pt] = {x = x,y = y}
    empty[x][y] = max_pt
    if x > max_x then max_x = x end
    if y > max_y then max_y = y end
    max_pt = max_pt + 1
end

max_pt = max_pt - 1
max_x = max_x + 1
max_y = max_y + 1

print(string.format("Got points: %d max_x: %d max_y: %d", max_pt, max_x, max_y))


local tabl = {}

for p = 0,max_pt do
    for x = 0,max_x do
        for y = 0,max_y do
            local distance = math.abs(pts[p].x - x) + math.abs(pts[p].y - y)
            --print(string.format("Doing: from %d,%d distance is %d to %d,%d", pts[p].x, pts[p].y, distance, x, y))
            if not tabl[x] then tabl[x] = {} end
            if not tabl[x][y] then tabl[x][y] = {} end
            tabl[x][y][p] = distance
        end
    end
end

flat = {}

for x = 0,max_x do
    for y = 0,max_y do
        local d = 0
        for p = 0,max_pt do
            d = d + tabl[x][y][p]
        end
        if not flat[x] then flat[x] = {} end
        flat[x][y] = d
    end
end

local t = 0

b = Bitmap.new(max_x+1, max_y+1)
--b:fill(1,1,max_x+1,max_y+1, {0,0,0})
for x = 0,max_x do
    for y = 0,max_y do
        local pt = flat[x][y]
        if pt < 10000 then
            t = t + 1
            px = {255, 0, 0}
            b:setPixel(x+1, y+1, px)
        end
    end
end

print("Found it: " .. tostring(t))

--for p = 0,max_pt do
    --b:setPixel(pts[p].x+1, pts[p].y+1, {255,0,0})
--end

b:writeP6("r.ppm")
--for y = 0,max_y do
--    local s = ""
--    for x = 0,max_x do
--        s = s .. string.format("%02d ", flat[x][y].pt)
--    end
--    print(s)
--end
--print()
--for y = 0,max_y do
--    local s = ""
--    for x = 0,max_x do
--        s = s .. string.format("%02d ", flat[x][y].distance)
--    end
--    print(s)
--end

local count = {}
for x=0,max_x do
    for y=0,max_y do
        local pt = flat[x][y].pt
        if pt >= 0 then
            count[pt] = (count[pt] or 0) + 1
        end
    end
end

for x = 0,max_x do
    local pt = flat[x][0].pt
    if pt >= 0 then count[pt] = -1 end
    local pt = flat[x][max_y].pt
    if pt >= 0 then count[pt] = -1 end
end

for y = 0,max_y do
    local pt = flat[0][y].pt
    if pt >= 0 then count[pt] = -1 end
    local pt = flat[max_x][y].pt
    if pt >= 0 then count[pt] = -1 end
end

local max = -1
for p = 0,max_pt do
    --print(string.format("%02d: %d", p, count[p] or -1))
    if count[p] > max then max = count[p] end
end
print(max)

b = Bitmap.new(max_x+1, max_y+1)
--b:fill(1,1,max_x+1,max_y+1, {0,0,0})
for x = 0,max_x do
    for y = 0,max_y do
        local pt = flat[x][y].pt
        if pt < 0 then
            px = {255,255,255}
        else
            px = {pt*4, pt*4, pt*4}
        end
        b:setPixel(x+1, y+1, px)
    end
end

for p = 0,max_pt do
    b:setPixel(pts[p].x+1, pts[p].y+1, {255,0,0})
end

b:writeP6("pic.ppm")

