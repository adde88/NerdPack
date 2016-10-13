local _, NeP = ...

-- Lowest
NeP.FakeUnits:Add('lowest', function(num, role)
	local tempTable = {}
	for _, Obj in pairs(NeP.Healing:GetRoster()) do
		if not role or (role and Obj.role == role:upper()) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = prio
			}
		end
	end
	return tempTable[num] and tempTable[num].key
end)

-- Lowest
NeP.FakeUnits:Add('tank', function(num)
	local tempTable = {}
	for _, Obj in pairs(NeP.Healing:GetRoster()) do
		if Obj.role == 'TANK' and not UnitIsUnit('player', Obj.key) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = prio
			}
		end
	end
	return tempTable[num] and tempTable[num].key
end)