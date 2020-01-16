#!/usr/bin/env lua

local D = false
local D_map = false
local D_water = false

function debug(...)
    if D then print(...) end
end

function debug_map(...)
    if D_map then print(...) end
end

function debug_water(...)
    if D_water then print(...) end
end

local mt_len = {
    __len = function(t)
        debug(t, "len", t.__len)
        return rawget(t, '__len') or 0
    end,
    __newindex = function(t, key, value)
        debug(t, "newindex", key)
        if key == "__len" then
            debug(t, key, '->', value)
            return rawset(t, key, value)
        end
        key = math.floor(tonumber(key))
        if type(key) ~= "number" then
            debug(t, "Key is not a number", key, type(key))
            error("Must insert numbers")
        end
        rawset(t, key, value)
        debug(t, "len is", #t)
        if key > #t then
            debug(t, "setting to", key)
            t.__len = key
        end
    end
}

local mt_all_sand = {
    __index = function(t, key)
        debug(t, "all sand", key)
        if key == "__len" then return rawget(t, key) end
        return '.'
    end,
    __len = mt_len.__len,
    __newindex = mt_len.__newindex,
}


local mt_infinite_table_sand = {
    __index = function(t, key)
        debug(t, "infinite", key)
        if key == "__len" then return rawget(t, key) end
        key = math.floor(tonumber(key))
        local n_t = setmetatable({}, mt_all_sand)
        rawset(t, key, n_t)
        if key > #t then
            t.__len = key
        end
        return n_t
    end,
    __len = mt_len.__len,
    __newindex = mt_len.__newindex,
}

local pile = setmetatable({}, mt_infinite_table_sand)

local lines = io.lines("input17-t.txt")
local lines = io.lines("input17.txt")
--local lines = io.lines("nathan17.input")
for l in lines do
    debug(l)
    local valx = {string.match(l, "x=(%d+), y=(%d+)..(%d+)")}
    if next(valx) then
        local x = valx[1]
        for y = math.floor(valx[2]),valx[3] do
            --print('x', x, y, '#')
            pile[y][x] = "#"
        end
    end
    local valy = {string.match(l, "y=(%d+), x=(%d+)..(%d+)")}
    if next(valy) then
        local y = math.floor(valy[1])
        for x = math.floor(valy[2]),valy[3] do
            --print('y', x, y, '#')
            pile[y][x] = "#"
        end
    end
end

debug(#pile)
function print_map(force)
    local p = false
    local count = 0
    local count_retain = 0
    local map = ""
    if D_map or force then p = true end

    if not p then return end

    for y=1,#pile do
        local l = string.format("%04d", y)
        for x=400,#pile[y] do
            if p then l = l .. pile[y][x] end
            if pile[y][x] == '~' or pile[y][x] == '|' then
                count = count + 1
            end
            if pile[y][x] == '~' then
                count_retain = count_retain + 1
            end
        end
        map = map .. l .. "\n"
    end
    --debug_map(map)
    if p then print(map) end
    print("Count", count)
    print("Count Retain", count_retain)
    return count
end

print_map()

local w_start = {
        { x = 500, y = 0, d='d' }
}
pile[w_start[1].y][w_start[1].x] = '|'

local zxc = -1000
local height = #pile

local sources = {
    { x= 500, y = 0, children = {} },
}

function purge_path_old(cur)
    debug_water("DONE source", cur.x, cur.y)
    local parent = cur.parent
    local child = cur
    local distance = 1
    while parent do
        local children = {}
        for k,v in pairs(parent.children) do
            if v ~= child then
                table.insert(children, v)
            else
                debug_water("found child")
            end
        end
        debug_water("cur/new", #parent.children, #children)
        parent.children = children
        if num_children == 0 then
            for k,v in pairs(sources) do
                if v == parent then
                    sources[k] = nil
                end
            end
        end
        debug_water(distance, parent.x, parent.y, #parent.children)
        child = parent
        parent = parent.parent
        distance = distance + 1
    end
    local packed = {}
    for k,v in pairs(sources) do
        --debug_water("sources", v.x, v.y, k)
        table.insert(packed, v)
    end
    sources = packed
    for k,v in pairs(sources) do
        debug_water("sources", v.x, v.y, k, #v.children)
    end
end

function remove_source(cur)
    if not cur.parent then return end
    local children = {}
    for k,v in pairs(cur.parent.children) do
        if v ~= cur then
            table.insert(children, v)
        else
            debug_water("found child")
        end
    end
    debug_water("cur/new", #cur.parent.children, #children)
    cur.parent.children = children
end

function purge_path(cur, full, dist)
    local d = dist or 0
    debug_water("DONE source", cur.x, cur.y, d)

    if (d == 0) or full then
        cur.purge = true
    end

    remove_source(cur)

    local parent = cur.parent
    if parent then
        if #parent.children == 0 then
            debug_water("DONE parent", #parent.children)
            purge_path(parent, full, d+1)
        end
    end 
    if d == 0 then
        local new_sources = {}
        for k,v in pairs(sources) do
            debug_water("sources", v.x, v.y, k, #v.children, v.purge)
            if not v.purge then
                table.insert(new_sources, v)
            end
        end
        sources = new_sources
        debug_water("Total sources", #sources)
    end
end



while #sources > 0 do
    ::next::
    print_map()
    local source_over = false
    local source = sources[#sources] --table.remove(sources)
    if not source then
        break
    end
    local x = source.x
    local y = source.y
    debug_water("source", x, y)
    y = y + 1
    while pile[y][x] == '.' or pile[y][x] == '|' do
        pile[y][x] = '|'
        debug_water("source d", x, y)
        y = y + 1
        local stream_over = false
        if y > height then
            debug_water("OVER", source.x, source.y, x, y)
            stream_over = true
        end
        -- We've hit water and merged
        if (not source.first_pass_done) and (pile[y][x] == '|') then
            debug_water("merge", source.x, source.y, x, y)
            stream_over = true
        end
        --if pile[y][x] == '|' then stream_over = true end
        if stream_over then
            purge_path(source, 'full')
            goto next
        end
    end

    y = y - 1

    source.first_pass_done = true

    if y == source.y then
        debug_water("source done, didn't move down")
        -- change last | to a water
        pile[y][x] = '~'
        source_over = true
        -- run the rest of the line "as the parent" since we're filling what we used to
        -- but the list is still the same, so table.remove kills the old source
        -- purge_path(source)
        -- Don't kill the while path, we're not at the end
        --remove_source(source)
        purge_path(source)
        source = source.parent
    end

    -- We're not at a local "bottom" hunt left and right
    --print_map(false)
    local initial_hunt_x = x
    local initial_hunt_y = y
    if pile[y][x] == '|' then pile[y][x] = '~' end
    local dir = {
        right = { op = function(x_i) return x_i + 1 end },
        left = { op = function(x_i) return x_i - 1 end },
    }
    local new_sources = {}
    local change_to_bar = {}
    for dir_name,dir_move in pairs(dir) do
        local x = initial_hunt_x
        local y = initial_hunt_y
        table.insert(change_to_bar, x)
        x = dir_move.op(x)
        debug_water("hunt_"..dir_name, x, y, pile[y][x])
        while (pile[y][x] == '.') or (pile[y][x] == '|') do
            debug_water("hunt " .. dir_name, x, y, #pile)
            table.insert(change_to_bar, x)
            pile[y][x] = '~'
            if pile[y+1][x] == '.' then
                pile[y][x] = '|'
                debug_water("new_source "..dir_name, x, y, #pile)
                local new_source = { x = x, y = y, parent = source, children = {} }
                table.insert(source.children, new_source)
                table.insert(new_sources, new_source)
                goto done_movement -- break
            else
                x = dir_move.op(x)
            end
        end
        ::done_movement::
    end
    if #new_sources > 0 then
        for k,x in pairs(change_to_bar) do
            pile[y][x] = '|'
        end
    end
    if source_over then
        debug_water("source over", x, y)
        --table.remove(sources)
        --purge_path(source)
    end
    for k,v in pairs(new_sources) do
        table.insert(sources, v)
    end
    --print_map(false)
    if ((-1*zxc) % 1000 == 0) then
        print("")
        print_map(true)
    end
    zxc = zxc - 1
    if zxc == 0 then
        print("")
        print_map(true)
        error('done r')
    end
    --print_map()
end
print_map(true)


--
--That's not the right answer; your answer is too high. If you're stuck, there
--are some general tips on the about page, or you can ask for hints on the
--subreddit. Please wait one minute before trying again. (You guessed 27742.)
--[Return to Day 17]- --
--
--That's not the right answer; your answer is too low. If you're stuck, there
--are some general tips on the about page, or you can ask for hints on the
--subreddit. Please wait one minute before trying again. (You guessed 27735.)
--[Return to Day 17]V
