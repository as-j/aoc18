#!/usr/bin/env lua

--pretty = require "pl.pretty"

local elf = arg[1] or 3
local goblin = arg[2] or 3
local die_early = arg[3]

local no_print = true

map = {}
units = {}
local y = 1
for line in io.lines("input15.txt") do
--for line in io.lines("input15-e1.tt") do
    local row = {}
    local x = 1
    local l = ""
    for c in line.gmatch(line, ".") do
        local attack = 3
        if c == 'G' then attack = goblin end
        if c == 'E' then attack = elf end
        if c == 'G' or c == 'E' then
            table.insert(units, {
                hp = 200,
                attack = attack,
                y = y,
                x = x,
                t = c
            })
        end
        table.insert(row, c)
        l = l .. c
        x = x + 1
    end
    table.insert(map, row)
    print(l)
    y = y + 1
end


function sort_units(units)
    table.sort(units, function(a, b)
        if a.y < b.y then return true end
        if a.y > b.y then return false end
        if a.x < b.x then return true end
        return false
    end)
end

function print_map_annot(map, anot)
    if no_print then return end
    local f = string.format("  ", 0)
    for x,_ in ipairs(map[1]) do
        f = string.format("%s%03d", f, x)
    end
    print(f)
    for y,row in ipairs(map) do
        local l = string.format("%03d ", y)
        for x,i in ipairs(row) do
            if anot[y] and anot[y][x] then
                local a = tostring(anot[y][x])
                l = l .. a
                if #a == 1 then
                    l = l .. '  '
                elseif #a == 2 then
                    l = l .. ' '
                end
            else
                l = l .. map[y][x] .. '  '
            end
        end
        print(l)
    end
end

function clear_screen()
    if not no_print then
        print("\x1B[2J\x1B[H")
    end
end
function home_screen()
    if not no_print then
        io.write("\x1B[H\x1B[2K")
    end
end

function clear_down()
    if not no_print then
        io.write("\x1B[J")
    end
end


it = 0
function do_dist(y, x, dist, dmap)

    it = it + 1
    --if (it%100000) == 0 then
        --io.write("\x1B[H\x1B[2K")
        --print(y, x, dist, it, #map[1])
        --print_map_annot(map, dmap)
    --end

    --print(y, x, dist)
    dmap[y][x] = dist
    if map[y][x+1] == '.' then
        local dm = dmap[y][x+1]
        if not dm or (dm > (dist+1)) then
            do_dist(y, x+1, dist+1, dmap)
        end
    end
    if map[y][x-1] == '.' then
        local dm = dmap[y][x-1]
        if not dm or (dm > (dist+1)) then
            do_dist(y, x-1, dist+1, dmap)
        end
    end
    if map[y+1][x] == '.' then
        local dm = dmap[y+1][x]
        if not dm or (dm > (dist+1)) then
            do_dist(y+1, x, dist+1, dmap)
        end
    end
    if map[y-1][x] == '.' then
        local dm = dmap[y-1][x]
        if not dm or (dm > (dist+1)) then
            do_dist(y-1, x, dist+1, dmap)
        end
    end
end

sort_units(units)
--pretty.dump(units)

function get_coords(unit)
    return {
        { y = unit.y-1, x = unit.x },
        { y = unit.y, x = unit.x - 1 },
        { y = unit.y, x = unit.x + 1 },
        { y = unit.y+1, x = unit.x }}
end

function print_map()
    if no_print then return end
    local empty = {}
    for _,_ in ipairs(map) do
        table.insert(empty, {})
    end
    print_map_annot(map, empty)
end

clear_screen()

round = 0
while true do
    sort_units(units)
    round = round + 1
    local loop = 0

    for i,unit in ipairs(units) do
        if unit.dead then goto skip end

        home_screen()
        print_map()
        clear_down()
        for j,unit in ipairs(units) do
            if unit.hp > 0 then
                --print(unit.t, unit.y, unit.x, unit.hp)
            end
        end

        loop = loop + 1
        --if loop > 11 then os.exit() end
        local enemies = {}
        for j,bad in ipairs(units) do
            if (bad.dead ~= true) and (unit.t ~= bad.t) then
                table.insert(enemies, bad)
            end
        end

        if #enemies == 0 then
            round = round - 1
            print_map()
            local sum = 0
            for j,unit in ipairs(units) do
                if not unit.dead then
                    --print(unit.t, unit.y, unit.x, unit.hp)
                    sum = sum + unit.hp
                end
            end
            print("over!", round, sum, round*sum)
            os.exit()
        end

        --print("*********", #enemies)
        --pretty.dump(unit)
        --pretty.dump(enemies)
        local coords = get_coords(unit)
        local attack = false

        for _,c in pairs(coords) do
            for _,bad in ipairs(enemies) do
                if (c.y == bad.y) and (c.x == bad.x) then
                    --print("ATTACK!", c.y, c.x)
                    attack = true
                end
            end
        end

        if not attack then
            local spots = {}
            for _,_ in ipairs(map) do
                table.insert(spots, {})
            end

            for j,bad in ipairs(enemies) do
                local x = bad.x
                local y = bad.y
                --print(x,y)
                if map[y-1][x] == '.' then spots[y-1][x] = '?' end
                if map[y+1][x] == '.' then spots[y+1][x] = '?' end
                if map[y][x-1] == '.' then spots[y][x-1] = '?' end
                if map[y][x+1] == '.' then spots[y][x+1] = '?' end
                --if map[y-1][x] == '.' then table.insert(spots, {y=y-1, x=x, t='?'}) end
                --if map[y+1][x] == '.' then table.insert(spots, {y=y+1, x=x, t='?'}) end
                --if map[y][x-1] == '.' then table.insert(spots, {y=y, x=x-1, t='?'}) end
                --if map[y][x+1] == '.' then table.insert(spots, {y=y, x=x+1, t='?'}) end
            end

            --pretty.dump({unit = unit})
            --pretty.dump(spots)
            --print("#spots", #spots)
            --print_map_annot(map, spots)

            local dmap = {}
            for _,_ in ipairs(map) do
                table.insert(dmap, {})
            end
            --clear_screen()
            do_dist(unit.y, unit.x, 0, dmap)
            --print_map_annot(map, dmap)

            local dist = {}
            for y,row in pairs(spots) do
                for x,v in pairs(row) do
                    table.insert(dist, {d = dmap[y][x], x = x, y = y})
                end
            end
            --pretty.dump({dist = dist})
            local min = { d = math.maxinteger, x = math.maxinteger, y = math.maxinteger}
            for _,v in pairs(dist) do
                if v.d and (v.d < min.d) then
                    min = v
                elseif v.d == min.d then
                    if v.y < min.y then
                        min = v
                    elseif v.y == min.y then
                        if v.x < min.x then
                            min = v
                        end
                    end
                end
            end
            if min.d == math.maxinteger then
                --pretty.dump({min = "nothing reachable"})
                goto next_unit
            end
            --pretty.dump({min = min})

            local dmap_ret = {}
            for _,_ in ipairs(map) do
                table.insert(dmap_ret, {})
            end
            do_dist(min.y, min.x, 0, dmap_ret)
            --print_map_annot(map, dmap_ret)

            local abs_min = math.maxinteger
            for k,c in pairs(coords) do
                c.dist = dmap_ret[c.y][c.x] or math.maxinteger
                if c.dist < abs_min then abs_min = c.dist end
            end
            for k,c in pairs(coords) do
                if c.dist > abs_min then coords[k] = nil end
            end
            local move_x
            local move_y
            for k=1,4 do
                if coords[k] then
                    move_y = coords[k].y
                    move_x = coords[k].x
                    break
                end
            end
            --pretty.dump({coords = coords, abs_min = abs_min, move_x = move_x, move_y = move_y})
            map[unit.y][unit.x] = '.'
            unit.x = move_x
            unit.y = move_y
            map[unit.y][unit.x] = unit.t

            local empty = {}
            for _,_ in ipairs(map) do
                table.insert(empty, {})
            end
            --print_map_annot(map, empty)
        end -- if not attack
        ::next_unit::

        local coords = get_coords(unit)
        local targets = {}
        for _,c in ipairs(coords) do
            for _,bad in ipairs(enemies) do
                if (c.y == bad.y) and (c.x == bad.x) then
                    --table.insert(targets, {y = c.y, x = c.x, hp = bad.hp})
                    table.insert(targets, bad)
                end
            end
        end
        if next(targets) then -- something to attack!
            --print("i am", unit.y, unit.x, unit.t)
            local least = math.maxinteger
            for k=1,#targets do
                if least > targets[k].hp then
                    least = targets[k].hp
                end
            end
            local idx_f
            for k=1,#targets do
                if targets[k].hp > least then
                    targets[k] = nil
                else
                    if not idx_f then
                        idx_f = k
                    end
                end
            end
            --pretty.dump({targets = targets})
            --pretty.dump({target = targets[idx_f]})
            local target = targets[idx_f]
            target.hp = target.hp - unit.attack
            --print("tar now", target.y, target.x, target.hp)
            if target.hp <= 0 then
                if die_early and (map[target.y][target.x] == 'E') then error("OH NOES an Elf Died!") end
                map[target.y][target.x] = '.'
                --pretty.dump({units = units})
                for u = 1,#units do
                    if units[u] == target then
                        units[u].dead = true
                    end
                end
            end
        else 
            --print("no att", unit.y, unit.x)
        end
        ::skip::
    end
    local np = no_print
    no_print = false
    home_screen()
    print_map()
    print("round", round, "##################################")
    clear_down()
    no_print = np
end

