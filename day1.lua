#!/usr/local/bin/lua

local sum = 0
local prev_freq = {}

local f_table = {}

local lines = io.lines("input1.txt")
for l in lines do
    table.insert(f_table, tonumber(l))
end

loops = 0
while true do
    loops = loops + 1
    for _,l in pairs(f_table) do
        sum = sum + tonumber(l)
        print(sum)
        if prev_freq[sum] then
            goto done
        end
        prev_freq[sum] = 1
    end
end

::done::
print(sum, loops)
