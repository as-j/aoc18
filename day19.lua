#!/usr/bin/env lua

pretty = require "pl.pretty"

local function make_reg(init)
    init = init or 0
    local reg
    reg = setmetatable({}, {
        __tostring = function()
            local t = {}
            for i=0,5 do
                table.insert(t, string.format("%d: %d", i, reg[i]))
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

local function make_cpu()
    local code = {}
    local reg = make_reg(1)
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
        bonr = function(x, y, z)
            local a = reg[x]
            local b = reg[y]
            reg[z] = a | b
            return reg[z]
        end,
        boni = function(x, y, z)
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
            print("Bound to", ip_bound)
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
        end
    }, {
        __tostring = function()
            local cur = code[ip+1]
            return string.format("IP is: %s\texec: %s\t%s\t%s\t%s\treg: %s", ip, cur[1], cur[2], cur[3], cur[4], reg)
        end
    })
end

local my_cpu = make_cpu()

local file = io.open("input19-decode.txt")
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

while true do
    print(my_cpu)
    my_cpu.execute()
    cntr = cntr + 1
end
