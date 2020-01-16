#!/usr/bin/env lua

--pretty = require "pl.pretty"

local max_players = 9
local max_marble = 25

local max_players = 10
local max_marble = 1618

local max_players = 13
local max_marble = 7999

local max_players = 452
local max_marble = 7078400
local scores = {}

local first = {
    v = 0,
    p = nil,
    n = nil,
}

first.n = first
first.p = first


local function insert_before(cur, value)
    local p = cur.p
    local n = cur.n
    local new = {
        v = value,
        p = p,
        n = cur
    }
    cur.p = new
    p.n = new

    --print(new, new.p, new.n, cur, cur.p, cur.n)

    return new
end

local function inc(cur, n)
    if not n then n = 1 end
    for i=1,n do cur = cur.n end
    return cur
end

local function dec(cur, n)
    if not n then n = 1 end
    for i=1,n do cur = cur.p end
    return cur
end

local function rem(cur)
    local n = cur.n
    local p = cur.p
    n.p = p
    p.n = n
    return cur.v,n
end

local function print_table(player, cur)
    local now = first
    local s = tostring(player) .. ": "
    repeat
        if now == cur then s = s .. '(' end
        s = s .. tostring(now.v)
        if now == cur then s = s .. ')' end
        s = s .. " "
        now = now.n
    until now == first
    print(s)
end

print_table(0, first)
local cur = first

player = 1

collectgarbage("stop")

for i = 1,max_marble do
    if (i % 23) == 0 then
        local score = i
        cur = dec(cur, 7)
        local rm
        rm,cur = rem(cur)
        score = score + rm
        scores[player] = (scores[player] or 0) + score
    else
        cur = inc(cur, 2)
        cur = insert_before(cur, i)
    end
    --print_table(player, cur)
    player = (player % max_players) + 1
end

--pretty.dump(scores)

max = 0
for _,v in pairs(scores) do
    if v > max then
        max = v
    end
end

print(max)
os.exit()
