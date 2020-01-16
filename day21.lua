#!/usr/bin/env lua

pretty = require "pl.pretty"

local function make_reg(init)
    init = init or 0
    local reg
    reg = setmetatable({}, {
        __tostring = function()
            local t = {}
            for i=0,5 do
                table.insert(t, string.format("%s: %s", i, reg[i]))
                --table.insert(t, reg[i])
            end
            return string.format("[ %s ]", table.concat(t, "\t"))
        end
    })
    for i=0,5 do
        reg[i] = 0
    end
    reg[0] = init
    return reg
end

local function make_cpu(init)
    local code = {}
    local reg = make_reg(init)
    local ip = 0
    local ip_bound = 0
    local ins = {
        addr = function(x, y, z)
            local a = reg[x]
            local b = reg[y]
            reg[z] = (a + b)
            return reg[z]
        end,
        addi = function(x, y, z)
            local a = reg[x]
            local b = y
            reg[z] = a + b
            return reg[z]
        end,

        mulr = function(x, y, z)
            local a = reg[x]
            local b = reg[y]
            reg[z] = a * b
            return reg[z]
        end,

        muli = function(x, y, z)
            local a = reg[x]
            local b = y
            reg[z] = a * b
            return reg[z]
        end,
        banr = function(x, y, z)
            local a = reg[x]
            local b = reg[y]
            reg[z] = a & b
            return reg[z]
        end,
        bani = function(x, y, z)
            local a = reg[x]
            local b = y
            reg[z] = a & b
            return reg[z]
        end,
        borr = function(x, y, z)
            local a = reg[x]
            local b = reg[y]
            reg[z] = a | b
            return reg[z]
        end,
        bori = function(x, y, z)
            local a = reg[x]
            local b = y
            reg[z] = a | b
            return reg[z]
        end,
        setr = function(x, y, z)
            local a = reg[x]
            reg[z] = a
            return reg[z]
        end,
        seti = function(x, y, z)
            local a = x
            reg[z] = a
            return reg[z]
        end,
        gtir = function(x, y, z)
            local a = x
            local b = reg[y]
            reg[z] = a > b and 1 or 0
            return reg[z]
        end,
        gtri = function(x, y, z)
            local a = reg[x]
            local b = y
            reg[z] = a > b and 1 or 0
            return reg[z]
        end,
        gtrr = function(x, y, z)
            local a = reg[x]
            local b = reg[y]
            reg[z] = a > b and 1 or 0
            return reg[z]
        end,
        eqir = function(x, y, z)
            local a = x
            local b = reg[y]
            reg[z] = a == b and 1 or 0
            return reg[z]
        end,
        eqri = function(x, y, z)
            local a = reg[x]
            local b = y
            reg[z] = a == b and 1 or 0
            return reg[z]
        end,
        eqrr = function(x, y, z)
            local a = reg[x]
            local b = reg[y]
            reg[z] = a == b and 1 or 0
            return reg[z]
        end,
    }
    return setmetatable({
        bind_ip = function(line)
            ip_bound = tonumber(string.match(line, "#ip (%d)"))
            --print("Bound to", ip_bound)
            ip = reg[ip_bound]
        end,
        load_line = function(line)
            local i = {string.match(line, "^(%a+) (%d+) (%d+) (%d+)")}
            for j = 2,4 do
                i[j] = tonumber(i[j])
            end
            --print("Loaded", i[1], ins[i[1]])
            table.insert(code, i)
        end,
        execute = function()
            local cur = code[ip+1]
            if not cur then
                print(reg)
                print("IP died at:", ip)
                error("done")
            end
            reg[ip_bound] = ip
            ins[cur[1]](cur[2], cur[3], cur[4])
            ip = reg[ip_bound] + 1
        end,
        get_ip = function()
            return ip
        end,
        get_reg = function(r)
            return reg[r]
        end,
    }, {
        __tostring = function()
            local cur = code[ip+1]
            if not cur then
                error("done")
            end
            return string.format("IP is: %s\texec: %s\t%s\t%s\t%s\treg: %s", ip, cur[1], cur[2], cur[3], cur[4], reg)
        end
    })
end

reg0ok = 10720162
reg0 = 1519750
reg0 = 68032250
--reg0 = 5743
--reg0 = 10000000
::again::

local my_cpu = make_cpu(reg0)

local file = io.open("input21.txt")
while true do
    line = file:read("*l")
    if not line then break end
    if string.match(line, "^#ip") then
        my_cpu.bind_ip(line)
    elseif string.match(line, "^.... ") then
        my_cpu.load_line(line)
    else
        print("Unknown: ", line)
    end
end

local cntr = 0
local last_cntr = 0
local smallest = 999999999
local largest = 0
local lowest = 99999999999999
local highest = 0
local reg4 = {}
local reg4_past = {}
local last_r4 = 0
local ok, err = xpcall(function()
    while true do
        if my_cpu.get_ip() == 28 then
            local size = 0
            for k,v in pairs(reg4_past) do
                size = size + 1
            end
            print(my_cpu, "cntr", cntr, "last cntr", last_cntr, "delta cnt", cntr - last_cntr, "\nsmall", smallest, "largest", largest, lowest, highest, "d_r4", last_r4 - my_cpu.get_reg(4), size)
            last_r4 = my_cpu.get_reg(4)
            if reg4_past[last_r4] then error("ended") end
            reg4_past[last_r4] = true
            if cntr - last_cntr < smallest then smallest = cntr - last_cntr end
            if cntr - last_cntr > largest then largest = cntr - last_cntr end
            last_cntr = cntr
            if my_cpu.get_reg(4) > highest then highest = my_cpu.get_reg(4) end
            if my_cpu.get_reg(4) < lowest then lowest = my_cpu.get_reg(4) end
            if my_cpu.get_reg(4) < reg0ok then
                table.insert(reg4, {my_cpu.get_reg(4), cntr})
            end
        end
        my_cpu.execute()
        cntr = cntr + 1
        if cntr > 20000000000 then
            reg0 = reg0 - 1
            print("reg0", reg0)
            print(my_cpu)
            print("Failed, trying: " .. reg0 .. " " .. cntr)
            error("over")
            --goto again
        end
    end
end, debug.traceback)
print("err", err)
print("cntr", cntr)
--print(reg4)
pretty.dump(reg4)
