#!/usr/local/bin/lua

local pl = require "pl.pretty"

local wrks = 5

local reqs = {}
local lines = io.open("input7.txt")
local line = lines:read("*all")
lines:close()

for pre,req in string.gmatch(line, "Step (.) must be finished before step (.) can begin.") do
    --print(pre, req)

    if not reqs[req] then reqs[req] = { ["pre"] = {} } end
    if not reqs[pre] then reqs[pre] = { ["pre"] = {} } end
    l = #(reqs[req].pre)
    reqs[req].pre[l+1] = pre
end

--pl.dump(reqs)

keys = {}
for k,_ in pairs(reqs) do
    keys[#keys+1] = k
end

table.sort(keys)

for _,k in ipairs(keys) do
    --print(k, #reqs[k].pre)
end

answer = {}
answer[0] = {}
for i=1,wrks do
    answer[0][i] = nil
end

cur_sec = 0

done = ""
done_time = {}

while next(reqs) ~= nil do
    nxt = {}
    for let,t in pairs(reqs) do
       if #t.pre == 0 and not t.at then
           nxt[#nxt+1] = let
       end
    end

    if #nxt == 0 then
        goto continue
    end

    table.sort(nxt)

    ::more_work::
    rem = table.remove(nxt, 1)

    time = string.byte(rem) - string.byte('A') + 61 

    free_w = nil
    for i = 1,wrks do
        if answer[cur_sec][i] == nil then
            free_w = i
            break
        end
    end

    if not free_w then
        goto continue
    end

    for i=cur_sec,cur_sec+time-1 do
        if not answer[i] then answer[i] = {} end
        answer[i][free_w] = rem
    end
    if done_time[cur_sec+time] then
        error("Overlapping!")
    end
    done_time[cur_sec+time] = rem

    reqs[rem].at = cur_sec + time

    if #nxt > 0 then
        goto more_work
    end

    ::continue::
    c = ""
    for i=1,wrks do
        c = c .. (answer[cur_sec][i] or '.') .. "\t"
    end
    print(cur_sec, c, '|', done, done_time[cur_sec] or '-')
    if done_time[cur_sec] then
        done = done .. done_time[cur_sec]
        reqs[done_time[cur_sec]] = nil
    end

    cur_sec = cur_sec + 1
    if answer[cur_sec] == nil then answer[cur_sec] = {} end

    for let,t in pairs(reqs) do
        if t.at and t.at == cur_sec then
            rem = let
            for let,t in pairs(reqs) do
                for idx,is_pre in pairs(t.pre) do
                    if is_pre == rem then
                        table.remove(t.pre, idx)
                    end
                end
            end
        end
    end
end
print(done, cur_sec)
