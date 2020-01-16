#!/usr/bin/env lua

local map = {}

local file = io.open("input-20.txt")
--local file = io.open("nath20.input")
local line = file:read()
--local line = '^WNE$'
--local line = '^ENWWW(NEEE|SSE(EE|N))$' -- 10 doors
--local line = '^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$' -- 18 doors
--local line = '^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS)W)W)W)WWWW' -- 31 doors
--local line = '^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$' -- 23 doors

local map = {}
map[0] = {}
map[0][0] = {v='X', d=0}

function send(x)
    coroutine.yield(x)
end

function receive(coro)
    local status,value = coroutine.resume(coro)
    return value
end

function make_reader(cur_line)
    local t={}
    string.gsub(cur_line, ".",function(c) table.insert(t,c) end)
    return coroutine.create( function ()
        while #t > 0 do
            send(table.remove(t, 1))
        end
    end)
end

function get_pt(map, x, y)
    if not map[y] then
        map[y] = {}
    end
    if not map[y][x] then
        map[y][x] = {v = '#'}
    end
    return map[y][x]
end

function print_map(map, t)
    local max_distance = 0
    local d_though = 0
    local min_x = math.maxinteger
    local max_x = math.mininteger
    local ys = {}
    for y,row in pairs(map) do
        table.insert(ys, y)
        local xs = {}
        for x,v in pairs(row) do
            table.insert(xs, x)
        end
        table.sort(xs)
        if #xs > 0 then
            --print(xs[1], xs[#xs], #xs)
            if xs[1] < min_x then min_x = xs[1] end
            if xs[#xs] > max_x then max_x = xs[#xs] end
        end
    end
    table.sort(ys)
    --print(ys[1], ys[#ys])
    local min_y = ys[1]
    local max_y = ys[#ys]

    print("x", min_x, max_x)
    print("y", min_y, max_y)

    local bm = {}

    function mk_empty()
        local row = {}
        table.insert(row, '#')
        for x=min_x,max_x do
            table.insert(row,'#')
        end
        table.insert(row, '#\n')
        table.insert(bm, table.concat(row))
    end

    mk_empty()
    for y=min_y,max_y do
        local row = {}
        table.insert(row, '     ')
        for x=min_x,max_x do
            local pt = get_pt(map, x, y)
            if t == 'd' then
                table.insert(row, string.format("%4s ", pt.d or "    "))
                if (pt.d or 0) > max_distance then max_distance = pt.d end
                if (pt.d or 0) >= 1000 then d_though = d_though + 1 end
            else
                table.insert(row, pt.v or '#')
            end
        end
        table.insert(row, '     \n')
        table.insert(bm, table.concat(row))
    end
    mk_empty()
    if t ~= 'd' then print(table.concat(bm)) end
    if t == 'd' then
        print(table.concat(bm))
        print("Max Distance", max_distance)
        print("Rooms with 1000", d_though)
    end
end

--function make_reader(cur_line)
--    local t = string.gsub(cur_line, '.', function(c) table.insert(t, c) end)
--    return {
--        char = function()
--            return table.remove(t, 1)
--        end,
--        remaining = function()
--            return table.concat(t)
--        end,
--    }
--end
--

print_map(map)

local depth = 1
local max_depth = depth
local distance = 0

function mk_map(reader, x, y, init_distance)
    local distance = init_distance
    if depth > max_depth then
        --print(depth)
        max_depth = depth
    end
    local i_x = x
    local i_y = y
    while true do
        local b = receive(reader)
        if not b then
            return
        end
        local pt = get_pt(map, x, y)
        if b == 'N' then
            local pt = get_pt(map, x, y)
            pt.v = '.'
            y = y - 1
            pt = get_pt(map, x, y)
            pt.v = '-'
            y = y - 1
            pt = get_pt(map, x, y)
            pt.v = '.'
            distance = distance + 1
            if (not pt.d or (pt.d > distance)) then pt.d = distance end
        elseif b == 'S' then
            local pt = get_pt(map, x, y)
            pt.v = '.'
            y = y + 1
            pt = get_pt(map, x, y)
            pt.v = '-'
            y = y + 1
            pt = get_pt(map, x, y)
            pt.v = '.'
            if (not pt.d or (pt.d > distance)) then pt.d = distance end
            pt.d = distance
        elseif b == 'E' then
            local pt = get_pt(map, x, y)
            pt.v = '.'
            x = x + 1
            pt = get_pt(map, x, y)
            pt.v = '|'
            x = x + 1
            pt = get_pt(map, x, y)
            pt.v = '.'
            distance = distance + 1
            if (not pt.d or (pt.d > distance)) then pt.d = distance end
        elseif b == 'W' then
            local pt = get_pt(map, x, y)
            pt.v = '.'
            x = x - 1
            pt = get_pt(map, x, y)
            pt.v = '|'
            x = x - 1
            pt = get_pt(map, x, y)
            pt.v = '.'
            distance = distance + 1
            if (not pt.d or (pt.d > distance)) then pt.d = distance end
        elseif b == '^' then
        elseif b == '$' then
        elseif b == '(' then
            depth = depth + 1
            mk_map(reader, x, y, distance)
        elseif b == '|' then
            return mk_map(reader, i_x, i_y, init_distance)
        elseif b == ')' then
            depth = depth - 1
            return
        end
    end
end


full_input = make_reader(line)
mk_map(full_input, 0, 0, 0)
local pt = get_pt(map, 0,0)
pt.v = 'X'
print_map(map)
print_map(map, 'd')

