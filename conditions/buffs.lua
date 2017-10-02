local _, NeP = ...
local _G = _G

local function UnitBuffL(target, spell, own)
  local name,_,_,count,_,_,expires,caster = _G.UnitBuff(target, spell, nil, own)
  return name, count, expires, caster
end

local function UnitDebuffL(target, spell, own)
  local name, _,_, count, _,_, expires, caster = _G.UnitDebuff(target, spell, nil, own)
  return name, count, expires, caster
end

local heroismBuffs = { 32182, 90355, 80353, 2825, 146555 }
NeP.DSL:Register("hashero", function()
  for i = 1, #heroismBuffs do
    local SpellName = NeP.Core:GetSpellName(heroismBuffs[i])
    if UnitBuffL('player', SpellName) then return true end
  end
end)

------------------------------------------ BUFFS -----------------------------------------
------------------------------------------------------------------------------------------
NeP.DSL:Register("buff", function(target, spell)
  return UnitBuffL(target, spell, 'PLAYER') ~= nil
end)

NeP.DSL:Register("buff.any", function(target, spell)
  return UnitBuffL(target, spell) ~= nil
end)

NeP.DSL:Register("buff.count", function(target, spell)
  local _, count = UnitBuffL(target, spell, 'PLAYER')
  return count or 0
end)

NeP.DSL:Register("buff.count.any", function(target, spell)
  local _, count = UnitBuffL(target, spell)
  return count or 0
end)

NeP.DSL:Register("buff.duration", function(target, spell)
  local buff,_,expires = UnitBuffL(target, spell, 'PLAYER')
  return buff and (expires - _G.GetTime()) or 0
end)

NeP.DSL:Register("buff.many", function(target, spell)
  local count = 0
  for i=1,40 do
    if UnitBuffL(target, i, 'PLAYER') == spell then count = count + 1 end
  end
  return count
end)

NeP.DSL:Register("buff.many.any", function(target, spell)
  local count = 0
  for i=1,40 do
    if UnitBuffL(target, i) == spell then count = count + 1 end
  end
  return count
end)

------------------------------------------ DEBUFFS ---------------------------------------
------------------------------------------------------------------------------------------

NeP.DSL:Register("debuff", function(target, spell)
  return  UnitDebuffL(target, spell, 'PLAYER') ~= nil
end)

NeP.DSL:Register("debuff.any", function(target, spell)
  return UnitDebuffL(target, spell) ~= nil
end)

NeP.DSL:Register("debuff.count", function(target, spell)
  local _,count = UnitDebuffL(target, spell, 'PLAYER')
  return count or 0
end)

NeP.DSL:Register("debuff.count.any", function(target, spell)
  local _,count = UnitDebuffL(target, spell)
  return count or 0
end)

NeP.DSL:Register("debuff.duration", function(target, spell)
  local debuff,_,expires = UnitDebuffL(target, spell)
  return debuff and (expires - _G.GetTime()) or 0
end)

NeP.DSL:Register("debuff.many", function(target, spell)
  local count = 0
  for i=1,40 do
    if UnitDebuffL(target, i, 'PLAYER') == spell then count = count + 1 end
  end
  return count
end)

NeP.DSL:Register("debuff.many.any", function(target, spell)
  local count = 0
  for i=1,40 do
    if UnitDebuffL(target, i) == spell then count = count + 1 end
  end
  return count
end)

----------------------------------------------------------------------------------------------

-- Counts how many units have the buff
-- USAGE: count(BUFF).buffs > = #
NeP.DSL:Register("count.enemies.buffs", function(_,buff)
  local n1 = 0
  for _, Obj in pairs(NeP.OM:Get('Enemy')) do
      if NeP.DSL:Get('buff')(Obj.key, buff) then
          n1 = n1 + 1
      end
  end
  return n1
end)

-- Counts how many units have the buff
-- USAGE: count(BUFF).buffs > = #
NeP.DSL:Register("count.friendly.buffs", function(_,buff)
  local n1 = 0
  for _, Obj in pairs(NeP.OM:Get('Roster')) do
      if NeP.DSL:Get('buff')(Obj.key, buff) then
          n1 = n1 + 1
      end
  end
  return n1
end)

-- Counts how many units have the debuff
-- USAGE: count(DEBUFF).debuffs > = #
NeP.DSL:Register("count.enemies.debuffs", function(_,debuff)
  local n1 = 0
  for _, Obj in pairs(NeP.OM:Get('Enemy')) do
      if NeP.DSL:Get('debuff')(Obj.key, debuff) then
          n1 = n1 + 1
      end
  end
  return n1
end)

-- Counts how many units have the debuff
-- USAGE: count(DEBUFF).debuffs > = #
NeP.DSL:Register("count.friendly.debuffs", function(_,debuff)
  local n1 = 0
  for _, Obj in pairs(NeP.OM:Get('Roster')) do
      if NeP.DSL:Get('debuff')(Obj.key, debuff) then
          n1 = n1 + 1
      end
  end
  return n1
end)
