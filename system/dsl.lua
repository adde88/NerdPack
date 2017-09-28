local _, NeP = ...
local _G = _G
local DSL = NeP.DSL

local function FilterNum(str)
	local type_X = type(str)
	if type_X == 'string' then
		return tonumber(str) or 0
	elseif type_X == 'boolean' then
		return str and 1 or 0
	elseif type_X == 'number' then
		return str
	end
	return 0
end

local comperatores_OP = {
	['>='] = function(arg1, arg2) return arg1 >= arg2 end,
	['<='] = function(arg1, arg2) return arg1 <= arg2 end,
	['=='] = function(arg1, arg2) return arg1 == arg2 end,
	['~='] = function(arg1, arg2) return arg1 ~= arg2 end,
	['>']  = function(arg1, arg2) return arg1 > arg2 end,
	['<']  = function(arg1, arg2) return arg1 < arg2 end
}

-- alias (LEGACY)
comperatores_OP['!='] = comperatores_OP['~=']
comperatores_OP['='] 	= comperatores_OP['==']

local math_OP = {
	['+']  = function(arg1, arg2) return arg1 + arg2 end,
	['-']  = function(arg1, arg2) return arg1 - arg2 end,
	['/']  = function(arg1, arg2) return arg1 / arg2 end,
	['*']  = function(arg1, arg2) return arg1 * arg2 end,
}

local DSL_OP = {
	['!']  = function(arg1, arg2, target) return not DSL.Parse(arg1, arg2, target) end,
	['@']  = function(arg,_,target) return NeP.Library:Parse(arg:gsub('%((.+)%)', ''), target, arg:match('%((.+)%)')) end,
}

local function _AND(Strg, Spell, Target)
	local Arg1, Arg2 = Strg:match('(.*)&(.*)')
	Arg1 = DSL.Parse(Arg1, Spell, Target)
	-- Dont process anything in front sence we already failed
	if not Arg1 then return false end
	Arg2 = DSL.Parse(Arg2, Spell, Target)
	return Arg1 and Arg2
end

local function _OR(Strg, Spell, Target)
	local Arg1, Arg2 = Strg:match('(.*)||(.*)')
	Arg1 = DSL.Parse(Arg1, Spell)
	-- Dont process anything in front sence we already hit
	if Arg1 then return true end
	Arg2 = DSL.Parse(Arg2, Spell, Target)
	return Arg1 or Arg2
end

local function FindNest(Strg)
	local Start, End = Strg:find('({.*})')
	local count1, count2 = 0, 0
	for i=Start, End do
		local temp = Strg:sub(i, i)
		if temp == "{" then
			count1 = count1 + 1
		elseif temp == "}" then
			count2 = count2 + 1
		end
		if count1 == count2 then
			return Start,  i
		end
	end
end

local function Nest(Strg, Spell, Target)
	local Start, End = FindNest(Strg)
	local Result = DSL.Parse(Strg:sub(Start+1, End-1), Spell, Target)
	Result = tostring(Result or false)
	Strg = Strg:sub(1, Start-1)..Result..Strg:sub(End+1)
	return DSL.Parse(Strg, Spell, Target)
end

local C = NeP.Cache.Conditions

local function ProcessCondition(Strg, Spell, Target)
	-- Unit prefix
	if not NeP.DSL:Exists(Strg:gsub("%((.+)%)", "")) then
		local unitID, rest = _G.strsplit('.', Strg, 2)
		unitID =  NeP.FakeUnits:Filter(unitID)[1]
		-- condition Target
		if unitID and _G.UnitExists(unitID) then
			Target = unitID
			Strg = rest
		else
			--escape early if the unit dosent exist
			return false
		end
	end
	-- Condition arguments
	local Args = Strg:match("%((.+)%)") or Spell
	Strg = Strg:gsub("%((.+)%)", "")
	Target = Target or 'player'

	C[Strg] = C[Strg] or {}
	C[Strg][Target] = C[Strg][Target] or {}

	--cacched
	if C[Strg][Target][Args] == nil then
		C[Strg][Target][Args] = DSL:Get(Strg)(Target, Args) or false
	end

	return C[Strg][Target][Args]
end

local function Comperatores(Strg, Spell, Target)
	local OP = ''
	--Need to scan for != seperately otherwise we get false positives by spells with "!" in them
	if Strg:find('!=') then
		OP = '!='
	else
		for Token in Strg:gmatch('[><=~!]') do OP = OP..Token end
	end
	--escape early if invalid token
	local func = comperatores_OP[OP]
	if not func then return false end
	--actual process
	local arg1, arg2 = Strg:match("(.*)"..OP.."(.*)")
	arg1, arg2 = DSL.Parse(arg1, Spell, Target), DSL.Parse(arg2, Spell, Target)
	arg1, arg2 = FilterNum(arg1), FilterNum(arg2)
	return func(arg1 or 1, arg2 or 1)
end

local function StringMath(Strg, Spell, Target)
	local tokens = "[/%*%+%-]"
	local OP = Strg:match(tokens)
	local arg1, arg2 = _G.strsplit(OP, Strg, 2)
	arg1, arg2 = DSL.Parse(arg1, Spell, Target), DSL.Parse(arg2, Spell, Target)
	arg1, arg2 = FilterNum(arg1), FilterNum(arg2)
	return math_OP[OP](arg1, arg2)
end

local function ExeFunc(Strg)
	local Args = Strg:match('%((.+)%)')
	if Args then Strg = Strg:gsub('%((.+)%)', '') end
	return _G[Strg](Args)
end

function NeP.DSL.Parse(Strg, Spell, Target)
	local pX = Strg:sub(1, 1)
	if Strg:find('{(.-)}') then
		return Nest(Strg, Spell, Target)
	elseif Strg:find('||') then
		return _OR(Strg, Spell, Target)
	elseif Strg:find('&') then
		return _AND(Strg, Spell, Target)
	elseif DSL_OP[pX] then
		Strg = Strg:sub(2);
		return DSL_OP[pX](Strg, Spell, Target)
	elseif Strg:find("func=") then
		Strg = Strg:sub(6);
		return ExeFunc(Strg)
	-- != needs to be seperate otherwise we end up with false positives
	elseif Strg:find('[><=~]') or Strg:find('!=') then
		return Comperatores(Strg, Spell, Target)
	elseif Strg:find("[/%*%+%-]") then
		return StringMath(Strg, Spell, Target)
	elseif Strg:find('%a') then
		return ProcessCondition(Strg, Spell, Target)
	end
	return Strg
end

NeP.Globals.DSL = {
	Get = NeP.DSL.Get,
	Register = NeP.DSL.Register,
	Parse = NeP.DSL.Parse
}
