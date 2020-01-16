#!/usr/local/bin/lua

local sum = 0
local prev_freq = {}

local f_table = {}

local function read_file(lines, t)
    t = t or {}
    local new_line = lines()
    if not new_line then
        return t
    end
    table.insert(t, new_line)
    return read_file(lines, t)
end

local lines = io.lines("input2.txt")
local file = read_file(lines)

for i = 1,#file do
    local first_line = file[i]
    for j = i+1,#file do
        local diff = 0
        local str1 = string.gmatch(first_line, ".")
        local str2 = string.gmatch(file[j], ".")
        local common = {}
        for c1 in str1 do
            local c2 = str2()
            if c1 ~= c2 then diff = diff + 1 end
            if c1 == c2 then table.insert(common, c1) end
            if diff > 1 then goto next end
        end
        print("Found", first_line, file[j], table.concat(common))
        os.exit()
        ::next::
    end
end
