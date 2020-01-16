#!/usr/local/bin/lua

local pl = require "pl.pretty"

local reqs = {}
local lines = io.open("input7.txt")
local line = lines:read("*all")
lines:close()

for pre,req in string.gmatch(line, "Step (.) must be finished before step (.) can begin.") do
    print(pre, req)

    if not reqs[req] then reqs[req] = { ["pre"] = {} } end
    if not reqs[pre] then reqs[pre] = { ["pre"] = {} } end
    l = #(reqs[req].pre)
    reqs[req].pre[l+1] = pre
end

pl.dump(reqs)

keys = {}
for k,_ in pairs(reqs) do
    keys[#keys+1] = k
end

table.sort(keys)

for _,k in ipairs(keys) do
    print(k, #reqs[k].pre)
end

answer = ""

while next(reqs) ~= nil do
    nxt = {}
    for let,t in pairs(reqs) do
       if #t.pre == 0 then
           nxt[#nxt+1] = let
       end
    end

    table.sort(nxt)

    print("Next", nxt[1])

    rem = nxt[1]
    if not rem then
        print_count()
    end

    answer = answer .. rem
    reqs[rem] = nil

    for let,t in pairs(reqs) do
        for idx,is_pre in pairs(t.pre) do
            if is_pre == rem then
                print("Remove", rem, let, idx)
                table.remove(t.pre, idx)
            end
        end
    end
end

print(answer)

