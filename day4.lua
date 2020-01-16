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

local lines = io.lines("input4.txt")
local file = read_file(lines)

table.sort(file)

local dflt_value
local zero_value
function zero_value(t, k) 
    rawset(t, k, 0)
    return 0 end
function dflt_value(t, k)
    local o = setmetatable({}, {__index = zero_value})
    rawset(t, k, o)
    return o
end

local current_guard
local sleep_min
local wake_min
local awake = setmetatable({}, {__index = dflt_value})

for _,v in ipairs(file) do 
    --print(v)
    local hr,min = string.match(v, '^.1518-..-.. (%d+):(%d+).')
    local sleep = string.match(v, "falls asleep$")
    local wake = string.match(v, "wakes up$")
    local ng = string.match(v, 'Guard #(%d+)')
    if ng then
        if sleep_min then
            for i = sleep_min,59 do
                awake[current_guard][i] = awake[current_guard][i] + 1
            end
        end
        current_guard = ng
        if hr ~= "00" then min = 0 end
        wake_min = min 
    elseif sleep then
        sleep_min = min
        --print("S:", min)
        wake_min = nil
    elseif wake then
        --print("W:", min,sleep_min)
        wake_min = min
        for i = sleep_min,wake_min-1 do
            awake[current_guard][i] = awake[current_guard][i] + 1
        end
        sleep_min = nil
    end
end

local max = 0
local max_guard

local everything_max = 0
local everything_max_guard = 0
local everything_max_min = 0

for k,v in pairs(awake) do
    local t_mins = 0
    local str = "G: " .. string.format("%04d", k) .. " "
    for i = 0,60 do
        c = string.format("%02d", v[i])
        str = str .. c
        t_mins = t_mins + v[i]
        if v[i] > everything_max then
            everything_max = v[i]
            everything_max_guard = k
            everything_max_min = i
        end
    end
    print(str .. " Total: " .. t_mins)
    if t_mins > max then
        max = t_mins
        max_guard = k
    end
end

print(max_guard, max)

local max_min = 0
local min = 0
for i = 0,60 do
    if awake[max_guard][i] > max_min then
        min = i
        max_min = awake[max_guard][i]
    end
end

print("Min/guard: ", min, max_guard, min*max_guard)
print("E: ", everything_max_min, everything_max_guard, everything_max_min*everything_max_guard)

