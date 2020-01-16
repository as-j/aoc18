#!/usr/local/bin/lua

loops = 0

local function do_sum(sum, prev_freq, t)
    local v = table.remove(t, 1)
    if not v then
        loops = loops + 1
        local lines = io.lines("input1.txt")
        for l in lines do
            table.insert(t, tonumber(l))
        end
        return do_sum(sum, prev_freq, t)
    end
    sum = sum + v
    if prev_freq[sum] then
        print("Loops: " .. loops, sum)
        return sum
    end
    prev_freq[sum] = 1
    print(sum, v)

    return do_sum(sum, prev_freq, t)
end


freq = do_sum(0, {}, {})
print(freq)

