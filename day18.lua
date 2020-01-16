#!/usr/bin/env lua

dbg  = require "debugger"

local function range_lower(val)
    if val < 1 then return 1 end
    return val
end

local function range_upper(val, max)
    if val > max then return max end
    return val
end


local function new_loc(c, map, row, col)
    local change_to = c
    return {
        what = function ()
            dbg()
            return c
        end,
        where = function()
            return row,col
        end,
        process = function()
            local n_trees = 0
            local n_l = 0
            for r=range_lower(row-1),range_upper(row+1, #map) do
                for c=range_lower(col-1),range_upper(col+1, #map[row]) do
                    if map[r][c].what() == '|' then n_trees = n_trees + 1 end
                    if map[r][c].what() == '#' then n_l = n_l + 1 end
                end
            end
            if (c == '.') and (n_trees >= 3) then
                change_to = '|'
            elseif (c == '|') and (n_l >= 3) then
                change_to = '#'
            elseif (c == '#') then
                if (n_l > 1) and (n_trees >= 1) then
                    change_to = '#'
                else
                    change_to = '.'
                end
            end
        end,
        change = function()
            c = change_to
        end,
    }
end

local lines = io.lines("input18-t.txt")
local lines = io.lines("input18.txt")

local mt = {}
mt.__tostring = function(map)
    local top = {}
    local tens = {"   "} 
    local dig = {"   "}
    for col=1,#map[1] do
        table.insert(tens, col%10)
        table.insert(dig, math.floor(col/10))
    end
    table.insert(top, table.concat(dig))
    table.insert(top, table.concat(tens))
    for row=1,#map do
        local r = {string.format("%02d ", row)}
        for col=1,#map[row] do
            table.insert(r, map[row][col].what())
        end
        table.insert(top, table.concat(r))
    end
    return table.concat(top, "\n")
end

local map = setmetatable({}, mt)

for l in lines do
    local z = ""
    local row = {}
    table.insert(map, row)
    for c in string.gmatch(l, ".") do
        --print(#map, #row+1)
        local loc = new_loc(c, map, #map, #row+1)
        table.insert(row, loc)
    end
end

print(map)
os.exit()

function tick(map)
    for row=1,#map do
        for col=1,#map[row] do
            map[row][col].process()
        end
    end
    for row=1,#map do
        for col=1,#map[row] do
            map[row][col].change()
        end
    end
end

function sum(map)
    local l = 0
    local w = 0
    local o = 0
    for row=1,#map do
        for col=1,#map[row] do
            local c = map[row][col].what()
            if c == '#' then
                l = l + 1
            elseif c == '|' then
                w = w + 1
            else
                o =o + 1
            end
        end
    end
    return l,w,o
end

print(map)

local looping
local diff

function isLoopFactory(sum)
   local prev = {} 

   local n_found = 0
   local special
   local n_special

   return function(sum)
       for k,v in pairs(prev) do
           if v == sum then
               print("found one")
               f = true
               n_found = n_found + 1
           end
       end
       if not f then
           table.insert(prev, s)
       end
   end
end

local term = 1000000000

for i = 1,1000000000 do
    tick(map)
    print("[H[2J")
    print(map)
    local lum,wood,open = sum(map)
    print(i, lum, wood, open)
    print(lum*wood)
    local s = lum*wood
    local f
    if s == special then
        looping = i - n_special
        n_special = i
        diff = term - i
        diff = diff % looping
        print("Diff", diff)
    end
    if n_found == 50 then
        special = lum*wood
        n_special = i
    end
    if special then print("Special at", n_special, special) end
    if looping then print("Loop", looping) end
    if diff then
        print("Diff", diff)
        if diff == 0 then
            print("Sum", s)
            break
        end
        diff = diff - 1
    end
    --os.execute('sleep 0.01')
end

local lum,wood = sum(map)
print(lum, wood)
print(lum*wood)

