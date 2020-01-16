#!/usr/bin/env lua

pretty = require "pl.pretty"

local reg = {}

training = {}
program = {}
local file = io.open("input16.txt")
while true do
    line = file:read("*l")
    if not line then break end
    if string.match(line, "^Before") then
        local reg = {string.match(line, "^Before: .(%d), (%d), (%d), (%d)")}
        local op = {string.match(file:read(), "^(%d+) (%d) (%d) (%d)")}
        local ans = {string.match(file:read(), "^After:.+(%d), (%d), (%d), (%d)")}
        for k,v in pairs(reg) do reg[k] = math.tointeger(v) end
        for k,v in pairs(op) do op[k] = math.tointeger(v) end
        for k,v in pairs(ans) do ans[k] = math.tointeger(v) end
        table.insert(training, {
            reg = reg,
            op = op,
            ans = ans})
    else
        local codes = {string.match(line, "^(%d+) (%d) (%d) (%d)")}
        if #codes == 4 then
            for k,v in pairs(codes) do codes[k] = math.tointeger(v) end
            table.insert(program, codes)
        end
    end
end

print("Len training", #training)
print("Len program", #program)

function cmp(a, b)
    return (a[0] == b[0]) and (a[1] == b[1]) and (a[2] == b[2]) and (a[3] == b[3])
end

local mt_reg = {
    __eq = cmp,
    __tostring = function (t) return string.format("[%s, %s, %s, %s]", t[0], t[1], t[2], t[3])  end,
    __index = function(t, key)
        if type(key) == "string" then key = math.tointeger(key) end
        if (key < 0) or (key > 3) then error(string.format("Tried to access invalid register: %d", key)) end
        local val = rawget(t, "." .. (key))
        return val
    end,
    __newindex = function(t, key, value)
        if (key < 0) or (key > 3) then error(string.format("Tried to write invalid register: %s", key)) end
        rawset(t, "." .. (key), value)
    end,
}

function copy_reg(reg)
    local ans = {}
    for k,v in pairs(reg) do
        ans[k] = v
    end
    return setmetatable(ans, mt_reg)
end

function load_reg(r)
    local t = setmetatable({}, mt_reg)
    for k,v in pairs(r) do
        t[k-1] = v
    end
    return t
end

local ops = {}
function assign_add(func)
    t = setmetatable({}, {
        __add = func,
        __tostring = function() return func() end})
    ops[tostring(t)] = t
    return t
end

function addr(whoami, ops)
    if not whoami then return "addr" end
    local a = reg[ops[2]]
    local b = reg[ops[3]]
    local dest = ops[4]
    --print('addr', a, b, dest)
    local ans = copy_reg(reg)
    --print('ans1', ans, dest, a+b)
    ans[dest] = (a + b)
    --print('ans2', ans, dest)
    return ans
end
assign_add(addr)

function addi(whoami, ops)
    if not whoami then return "addi" end
    local a = reg[ops[2]]
    local b = ops[3]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a + b
    return ans
end
assign_add(addi)

assign_add(function(whoami, ops)
    if not whoami then return "mulr" end
    local a = reg[ops[2]]
    local b = reg[ops[3]]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a * b
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "muli" end
    local a = reg[ops[2]]
    local b = ops[3]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a * b
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "banr" end
    local a = reg[ops[2]]
    local b = reg[ops[3]]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a & b
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "bani" end
    local a = reg[ops[2]]
    local b = ops[3]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a & b
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "bonr" end
    local a = reg[ops[2]]
    local b = reg[ops[3]]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a | b
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "boni" end
    local a = reg[ops[2]]
    local b = ops[3]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a | b
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "setr" end
    local a = reg[ops[2]]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "seti" end
    local a = ops[2]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "gtir" end
    local a = ops[2]
    local b = reg[ops[3]]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a > b and 1 or 0
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "gtri" end
    local a = reg[ops[2]]
    local b = ops[3]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a > b and 1 or 0
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "gtrr" end
    local a = reg[ops[2]]
    local b = reg[ops[3]]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a > b and 1 or 0
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "eqir" end
    local a = ops[2]
    local b = reg[ops[3]]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a == b and 1 or 0
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "eqri" end
    local a = reg[ops[2]]
    local b = ops[3]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a == b and 1 or 0
    return ans
end)

assign_add(function(whoami, ops)
    if not whoami then return "eqrr" end
    local a = reg[ops[2]]
    local b = reg[ops[3]]
    local dest = ops[4]
    local ans = copy_reg(reg)
    ans[dest] = a == b and 1 or 0
    return ans
end)

reg = load_reg{1,2,3,4}
op = {9, 0, 1, 3}


print(reg)
print(ops.addr + op)
print(ops.addi + op)
print(ops.eqri + op)

--pretty.dump(training)
for op in pairs(ops) do
    print(op)
end

codes = {}
for code=0,15 do
    codes[code] ={}
    for opname,op in pairs(ops) do
        codes[code][opname] = op
    end
end

--pretty.dump(codes)
total = 0
for i,t in ipairs(training) do
    --pretty.dump(t)
    reg = load_reg(t.reg)
    local ans_reg = load_reg(t.ans)
    local op_code = t.op[1]
    --pretty.dump(t.op)
    n = 0
    for name,op in pairs(codes[op_code]) do
        if op then
            --print(i, j, op)
            --pretty.dump(t.op)
            local my = op + t.op
            --print(op, op_code, t.op[2], t.op[3], t.op[4], reg, '->', my, 'want', ans_reg)
            if tostring(my) ~= tostring(ans_reg) then
                --print("Kill", op)
                codes[op_code][name] = nil
            else
                n = n + 1
                --print("Match", op)
            end
        end
    end
    --print(n)
    if n >= 3 then
        total = total + 1
    end
    --pretty.dump(codes[op_code])
    --os.exit()
end

--pretty.dump(codes)

more_t = 0
final = {}
::again::
for op_code,names in pairs(codes) do
    n = 0
    local code
    for k,v in pairs(names) do
        n = n + 1
        code = v
    end
    --print(op_code, n, code)
    if n == 1 then
        local old_op = op_code
        --print("removing", code)
        final[op_code] = code
        codes[op_code] = nil
        for op_code, names in pairs(codes) do
            for k,v in pairs(names) do
                if v == code then
                    names[k] = nil
                end
            end
        end
        goto again
    end
end
--pretty.dump(codes)

for op_code, name in pairs(final) do
    --print(op_code, name)
end

--print(total)
for i = 0,#final do
    print(i, final[i])
end

reg = load_reg{0,0,0,0}
for i = 1,#program do
    local line = program[i]
    local op = final[line[1]]
    local new_reg = op + line
    --print(i, op)
    print(i, op, new_reg)
    reg = new_reg
end
