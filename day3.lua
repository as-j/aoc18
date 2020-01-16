#!/usr/local/bin/lua

dbg = require "debugger"

local sum = 0
local prev_freq = {}

local f_table = {}

local function read_file(lines, t)
    t = t or {}
    local new_line = lines()
    if not new_line then
        return t
    end
    local claim,x,y,width,height = string.match(new_line, "^#(%d+) @ (%d+),(%d+): (%d+)x(%d+)")
    table.insert(t, { x = x,
                      y = y,
                      width = width,
                      height = height})
    return read_file(lines, t)
end

local lines = io.lines("input3.txt")
local file = read_file(lines)

local sheet = {}

local competing = 0

for i = 1,#file do
    local claim = file[i]
    local overlap = false
    for x = claim.x,claim.x+claim.width-1 do
        for y = claim.y,claim.y+claim.height-1 do
            sheet[y] = sheet[y] or {}
            if sheet[y][x] then
                local o_i = sheet[y][x]
                if o_i ~= 'X' then
                    file[o_i].overlap = true
                    competing = competing + 1
                end
                file[i].overlap = true
                sheet[y][x] = 'X'
                overlap = true
            else
                sheet[y][x] = i
            end
        end
    end
end

for i = 1,#file do
    if not file[i].overlap then
        print("No overlap for: " .. i)
    end
end

local c2 = 0

for y,_ in pairs(sheet) do
    for x,_ in pairs(sheet) do
        if sheet[y][x] == 'X' then c2 = c2 + 1 end
    end
end

print(competing, c2)
