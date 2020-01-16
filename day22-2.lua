#!/usr/local/bin/lua

local depth = 510
local target = {x = 10, y = 10}
local t_width = {x = 15, y = 15}

local depth = 7863
local target = { x = 14,y  = 760}
--local target = { x = 10,y  = 10}
local t_width = {x = 40, y = 850}
--local t_width = {x = 20, y = 160}

local width = t_width.x
local height = t_width.y

local y0_x = 16807
local x0_y = 48271
local base_mod = 20183

local debug_p = false

local sym_to_name = {
    ["."] = "rocky",
    ["|"] = "narrow",
    ["="] = "wet",
    ["M"] = "rocky",
    ["T"] = "rocky",
}

local function home_screen()
    io.write("\x1B[H\x1B[2K")
end

local function clear_screen()
    print("\x1B[2J\x1B[H")
end

local function dprint(...)
    if debug_p then
        print(...)
    end
end

local function min_cost(cost)
    local min = 999999
    if not cost then
        return min
    end
    if cost["neither"] and min > cost["neither"] then
        min = cost["neither"]
    end
    if cost["climbing"] and min > cost["climbing"] then
        min = cost["climbing"]
    end
    if cost["torch"] and min > cost["torch"] then
        min = cost["torch"]
    end
    return min
end

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
local vmap = {}
for y=0,height do
    local line = {}
    local vline = {}
    for x=0,width do
        local char = '.'
        sum = sum + map[y][x].type
        if map[y][x].type == 1 then char = '=' end
        if map[y][x].type == 2 then char = '|' end
        if x == 0 and y == 0 then char = 'M' end
        if y == target.y and x == target.x then char = 'T' end
        table.insert(line, char)
        table.insert(vline, char)
    end
    table.insert(vmap, vline)
    table.insert(pmap, table.concat(line))
    print(table.concat(line))
end
print("risk", sum)

function cost_map()
    local pmap = {}
    local sum = 0
    for y=0,height do
    --for x=0,width do
        local line = {}
        for x=0,width do
        --for y=0,height do
            local char
            if y == target.y and x == target.x then
                char = string.format("X%04dX", min_cost(map[y][x].cost) or 0)
            elseif map[y][x].cost then
                char = string.format(" %04s ", min_cost(map[y][x].cost))
            else
                char = "      "
            end
            table.insert(line, char)
        end
        table.insert(pmap, table.concat(line))
    end
    print(table.concat(pmap, "\n"))
end

local gear = "torch"

local options = {
    [0] = {"climbing", "torch"},
    [1] = {"climbing", "neither"},
    [2] = {"torch", "neither"},
}

function get_cost(from_x, from_y, to_x, to_y, cur_gear)
    local from_type = map[from_y][from_x].type
    local to_type = map[to_y][to_x].type
    if from_type == to_type then
        dprint(from_x, from_y, to_x, to_y, "same type", cur_gear)
        return 1, cur_gear, 0
    end
    local to_gear = options[to_type]
    if (cur_gear == to_gear[1]) or (cur_gear == to_gear[2]) then
        dprint(from_x, from_y, to_x, to_y, "keeping", cur_gear)
        return 1, cur_gear, 0
    end
    local pos_gear = options[from_type]
    for k,possible in ipairs(pos_gear) do
        if (possible == to_gear[1]) or (possible == to_gear[2]) then
            dprint(from_x, from_y, to_x, to_y, "switch to", cur_gear, possible)
            return 8, possible, 1
        end
    end
    return nil, "not possible"
end

local r = 0
local f = 0
local target_cost = 1057
function travel(x, y, cost, gear, route, switch)
    if x == target.x and y == target.y then
        if gear ~= "torch" then
            cost = cost + 7
            gear = "torch"
        end
        if not map[y][x].cost or not map[y][x].cost[gear] or cost <= map[y][x].cost[gear] then
            if not map[y][x].cost then map[y][x].cost = {} end
            if cost < target_cost then target_cost = cost end
            map[y][x].cost[gear] = cost
            map[y][x].route = route
            map[y][x].switch = switch
            --home_screen()
            print(min_cost(map[y][x].cost), route, #route)
        end
        --home_screen()
        --cost_map()
        f = f + 1
        --if f < 2 then return true end
        return
    end
    --if #route > (width*height+20) then error("boom? " .. #route ) end
    r = r + 1
    if (r % 250000) == 0 then
        print("partial", x, y, #route, route)
        --print(x, y, route)
        --home_screen()
        --cost_map()
    end
    if map[y][x].cost and map[y][x].cost[gear] and cost >= map[y][x].cost[gear] then
        dprint(x, y, "already has lower cost", map[y][x].cost, cost)
        return
    end

    if cost > target_cost then
        dprint(x, y, "already has lower target cost", map[y][x].cost, cost, target_cost)
        return
    end

    map[y][x].visited = true

    dprint(x, y, "looking around", cost, gear)
    dprint("down", x, y)
    if not map[y][x].cost then map[y][x].cost = {} end
    map[y][x].cost[gear] = cost
    next_x = x
    next_y = y + 1
    if next_y >= 0 and next_y <= height and not map[next_y][next_x].visited then
        local new_cost,new_gear,gear_switch = get_cost(x, y, next_x, next_y, gear)
        dprint(x, y, "new cost", new_cost)
        if new_cost then
            local unwind = travel(next_x, next_y, cost + new_cost, new_gear, route .. 'd', switch+gear_switch)
            if unwind then return end
        end
    end

    next_x = x + 1
    next_y = y
    if next_x >= 0 and next_x <= width and not map[next_y][next_x].visited then
        local new_cost,new_gear, gear_switch = get_cost(x, y, next_x, next_y, gear)
        if new_cost then
            local unwind = travel(next_x, next_y, cost + new_cost, new_gear, route .. 'r', switch+gear_switch)
            if unwind then return end
        end
    end

    next_x = x
    next_y = y - 1
    if next_y >= 0 and next_y <= height and not map[next_y][next_x].visited then
        local new_cost,new_gear, gear_switch = get_cost(x, y, next_x, next_y, gear)
        if new_cost then
            local unwind = travel(next_x, next_y, cost + new_cost, new_gear, route .. 'u', switch+gear_switch)
            if unwind then return end
        end
    end

    next_x = x - 1
    next_y = y
    if next_x >= 0 and next_x <= width and not map[next_y][next_x].visited then
        local new_cost,new_gear, gear_switch = get_cost(x, y, next_x, next_y, gear)
        if new_cost then
            local unwind = travel(next_x, next_y, cost + new_cost, new_gear, route .. 'l', switch+gear_switch)
            if unwind then return end
        end
    end

    dprint("up", x, y)
    map[y][x].visited = false
end

clear_screen()
travel(0, 0, 0, "torch", "", 0)
print("Cost",min_cost(map[target.y][target.x].cost), map[target.y][target.x].route, #map[target.y][target.x].route, map[target.y][target.x].switch, "loops", r)

local test_sum = 0
local test_route = "drrrrdddddddrdddrdrrrruu"
local s_x = 0
local s_y = 0
local tool = 'torch'
print(c, test_sum, vmap[1][1])
string.gsub(test_route, ".", function(c)
    if c == 'd' then s_y = s_y + 1 end
    if c == 'u' then s_y = s_y - 1 end
    if c == 'r' then s_x = s_x + 1 end
    if c == 'l' then s_x = s_x - 1 end
    local min = 9000
    if map[s_y][s_x].cost["neither"] and min > map[s_y][s_x].cost["neither"] then
        tool = 'neither'
        min = map[s_y][s_x].cost["neither"]
    end
    if map[s_y][s_x].cost["climbing"] and min > map[s_y][s_x].cost["climbing"] then
        tool = 'climbing'
        min = map[s_y][s_x].cost["climbing"]
    end
    if map[s_y][s_x].cost["torch"] and min > map[s_y][s_x].cost["torch"] then
        tool = 'torch'
        min = map[s_y][s_x].cost["torch"]
    end
    test_sum = min
    print(c, test_sum, tool, vmap[s_y+1][s_x+1], sym_to_name[vmap[s_y+1][s_x+1]])
end)

print("Test route", s_x, s_y, test_sum)
