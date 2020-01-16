#!/usr/bin/env lua

local lines = io.lines("input24.txt")

local pl_pretty = require 'pl.pretty'


local force
local system = {}
for l in lines do
    if string.match(l, ":$") then
        force = string.match(l, "(.+):$")
        print(force)
        system[force] = {}
    elseif string.match(l, " units ") then
        local units, hp, powers, at, att, init
        units = string.match(l, "(%d+) units")
        hp = string.match(l, "(%d+) hit points")
        powers = string.match(l, "%(([^)]+)")
        at,att = string.match(l, "that does (%d+) ([^ ]+)")
        init = string.match(l, "initiative (%d)")
        print(units, hp, powers, at, att, init)
        local t = {
            force = force,
            init = init,
            units = units,
            hp = hp,
            powers = {},
            at = at,
            at_type = att,
            init = init,
        }
        table.insert(system, t)
        if not powers then powers = "" end
        for m in string.gmatch(powers, "([^;]+);? ?") do
            local style,items = string.match(m, "(%S+) to (.+)")
            t[style] = {}
            for i in string.gmatch(items, "([^,]+),? ?") do
                t[style][i] = true
            end
        end
    end
end

function target_selection() 
    local eff_pwr = {}
    for k,v in ipairs(system) do
        v.target = nil
        v.attacker = nil
        eff_pwr[k] = v
    end
    table.sort(eff_pwr, function(a, b)
        local a_pwr = a.units * a.at
        local b_pwr = b.units * b.at
        if b_pwr < a_pwr then return true end
        if b_pwr > a_pwr then return false end
        if b.init < a.init then return true end
        return false
    end)
    for k,v in ipairs(eff_pwr) do
        print("eff", v.units * v.at, v.force, v.units, v.init, v.at_type)
        local at_type = v.at_type
        local eff = v.units * v.at
        local max_damage = 0
        local the_target = nil
        for t_k,t_v in ipairs(system) do
            if (t_v.force ~= v.force) and (not t_v.attacker) then
                local weak, immune
                local t_eff = eff
                if t_v.weak then weak = t_v.weak[at_type] end
                if t_v.immune then immune = t_v.immune[at_type] end
                if weak then t_eff = 2 * eff end
                if immune then t_eff = 0 end
                print("looking at", t_v.force, t_v.units, 'weak', weak, 'immune', immune, 't_eff', t_eff)
                if max_damage < t_eff then
                    print("Picking", t_eff)
                    max_damage = t_eff
                    the_target = t_v
                end
            end
        end
        print("picked", the_target.force, the_target.units)
        v.target = the_target
        if the_target then the_target.attacker = v end
    end
    pl_pretty.dump(eff_pwr)
end

target_selection()
