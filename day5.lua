#!/usr/local/bin/lua

local upper = string.upper
local gmatch = string.gmatch
local byte = string.byte

local empty = {}
local lines = io.open("input5.txt")
local line = lines:read("*all")
lines:close()

for c in gmatch(line, ".") do
    table.insert(empty, c)
end

for k,v in pairs(empty) do
    empty[k] = nil
end

--for val = 0x41,0x5A do
for val = 0x40,0x40 do
    local remove = string.char(val)
    local lines = io.open("input5.txt")
    local line = lines:read("*all")
    lines:close()

    local chars = {}
    for c in gmatch(line, ".") do
        if upper(c) ~= remove then
            table.insert(chars, c)
        end
    end

    local start = #chars

    local did_any = 1
    local loops = 0
    local new = {}
    local a = {}
    while did_any ~= 0 do
        new = {}
        local new_k = 1
        local k = 1
        did_any = 0
        while k <= #chars do
            local c = chars[k]
            local n = chars[k+1] or " "
            local c_b = byte(c)
            local c_n = byte(n)
            local found = 0
            if ((c_b|0x20) == (c_n|0x20)) and (c_b ~= c_n) then
                k = k + 2
                did_any = did_any + 1
            else
                new[new_k] = chars[k]
                new_k = new_k + 1
                k = k + 1
            end
        end
        chars = new
        loops = loops + 1
        --print(table.concat(new, ""))
    end
    print(remove, start, #new-1, loops)
end

